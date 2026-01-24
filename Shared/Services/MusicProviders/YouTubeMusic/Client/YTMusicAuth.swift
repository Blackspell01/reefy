//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import KeychainSwift
import Logging

/// Handles OAuth 2.0 Device Flow authentication for YouTube Music
///
/// Device Flow is used because tvOS has no browser. The flow works like this:
/// 1. App requests a device code from Google
/// 2. User sees a code on screen (e.g., "ABCD-EFGH")
/// 3. User visits google.com/device on their phone/computer
/// 4. User enters the code to authorize
/// 5. App polls Google until authorization completes
///
/// Reference: https://developers.google.com/identity/protocols/oauth2/limited-input-device
final class YTMusicAuth: ObservableObject {

    // MARK: - Types

    /// Current state of the authentication flow
    enum AuthState: Equatable {
        case idle
        case awaitingUserAction(DeviceCodeResponse)
        case polling
        case authenticated
        case failed(YTMusicError)
    }

    /// Response from the device code request
    struct DeviceCodeResponse: Equatable, Codable {
        let deviceCode: String
        let userCode: String
        let verificationUrl: String
        let expiresIn: Int
        let interval: Int

        enum CodingKeys: String, CodingKey {
            case deviceCode = "device_code"
            case userCode = "user_code"
            case verificationUrl = "verification_url"
            case expiresIn = "expires_in"
            case interval
        }
    }

    /// OAuth token response
    struct TokenResponse: Codable {
        let accessToken: String
        let refreshToken: String?
        let expiresIn: Int
        let tokenType: String
        let scope: String?

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case expiresIn = "expires_in"
            case tokenType = "token_type"
            case scope
        }
    }

    /// Error response from OAuth endpoints
    private struct OAuthErrorResponse: Codable {
        let error: String
        let errorDescription: String?

        enum CodingKeys: String, CodingKey {
            case error
            case errorDescription = "error_description"
        }
    }

    // MARK: - Properties

    @Published private(set) var state: AuthState = .idle

    private let keychain: KeychainSwift
    private let logger = Logger.swiftfin()
    private var pollingTask: Task<Void, Never>?

    /// Current access token (nil if not authenticated)
    var accessToken: String? {
        keychain.get(Keys.accessToken)
    }

    /// Whether the user is currently authenticated
    var isAuthenticated: Bool {
        accessToken != nil
    }

    /// Token expiration date
    private var tokenExpirationDate: Date? {
        guard let expirationString = keychain.get(Keys.tokenExpiration),
              let expiration = Double(expirationString)
        else {
            return nil
        }
        return Date(timeIntervalSince1970: expiration)
    }

    /// Whether the current token has expired
    var isTokenExpired: Bool {
        guard let expirationDate = tokenExpirationDate else { return true }
        return Date() >= expirationDate
    }

    // MARK: - OAuth Configuration

    // Note: These are placeholder values. In production, you would:
    // 1. Create a project in Google Cloud Console
    // 2. Enable YouTube Data API v3
    // 3. Create OAuth 2.0 credentials for "TV and Limited Input devices"
    // 4. Store these securely (not in code)
    private enum OAuth {
        static let clientID = "YOUR_CLIENT_ID.apps.googleusercontent.com"
        static let clientSecret = "YOUR_CLIENT_SECRET"
        static let scope = "https://www.googleapis.com/auth/youtube"
        static let deviceCodeURL = URL(string: "https://oauth2.googleapis.com/device/code")!
        static let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
    }

    // MARK: - Keychain Keys

    private enum Keys {
        static let accessToken = "ytmusic_access_token"
        static let refreshToken = "ytmusic_refresh_token"
        static let tokenExpiration = "ytmusic_token_expiration"
    }

    // MARK: - Initialization

    init(keychain: KeychainSwift = KeychainSwift()) {
        self.keychain = keychain
        keychain.accessGroup = nil // Use app's default keychain

        // Check if we have stored credentials
        if accessToken != nil && !isTokenExpired {
            state = .authenticated
        }
    }

    // MARK: - Public Methods

    /// Start the device flow authentication process
    ///
    /// This will request a device code and update `state` to `.awaitingUserAction`
    /// with the code and verification URL to show the user.
    @MainActor
    func startAuthentication() async throws {
        state = .idle

        let deviceCode = try await requestDeviceCode()
        state = .awaitingUserAction(deviceCode)
    }

    /// Begin polling for authorization after user sees the code
    ///
    /// Call this after presenting the device code to the user.
    /// The flow will automatically complete when the user authorizes.
    @MainActor
    func startPolling() async {
        guard case let .awaitingUserAction(deviceCode) = state else {
            logger.warning("startPolling called without device code")
            return
        }

        state = .polling
        pollingTask?.cancel()

        pollingTask = Task { [weak self] in
            await self?.pollForToken(deviceCode: deviceCode)
        }
    }

    /// Cancel the current authentication flow
    @MainActor
    func cancelAuthentication() {
        pollingTask?.cancel()
        pollingTask = nil
        state = .idle
    }

    /// Refresh the access token using the stored refresh token
    @MainActor
    func refreshAccessToken() async throws {
        guard let refreshToken = keychain.get(Keys.refreshToken) else {
            throw YTMusicError.notAuthenticated
        }

        let token = try await requestTokenRefresh(refreshToken: refreshToken)
        storeToken(token)
        state = .authenticated
    }

    /// Sign out and clear stored credentials
    @MainActor
    func signOut() {
        pollingTask?.cancel()
        pollingTask = nil

        keychain.delete(Keys.accessToken)
        keychain.delete(Keys.refreshToken)
        keychain.delete(Keys.tokenExpiration)

        state = .idle
    }

    /// Get a valid access token, refreshing if necessary
    func getValidAccessToken() async throws -> String {
        if let token = accessToken, !isTokenExpired {
            return token
        }

        // Try to refresh
        try await refreshAccessToken()

        guard let token = accessToken else {
            throw YTMusicError.notAuthenticated
        }

        return token
    }

    // MARK: - Private Methods

    /// Request a device code from Google
    private func requestDeviceCode() async throws -> DeviceCodeResponse {
        var request = URLRequest(url: OAuth.deviceCodeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "client_id": OAuth.clientID,
            "scope": OAuth.scope,
        ]
        request.httpBody = body.urlEncodedString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw YTMusicError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            throw YTMusicError.httpError(statusCode: httpResponse.statusCode, message: nil)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(DeviceCodeResponse.self, from: data)
    }

    /// Poll for token until user authorizes or times out
    private func pollForToken(deviceCode: DeviceCodeResponse) async {
        let deadline = Date().addingTimeInterval(TimeInterval(deviceCode.expiresIn))
        let interval = TimeInterval(deviceCode.interval)

        while Date() < deadline {
            guard !Task.isCancelled else {
                await MainActor.run { state = .idle }
                return
            }

            // Wait the required interval
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))

            do {
                let token = try await requestToken(deviceCode: deviceCode.deviceCode)

                await MainActor.run {
                    storeToken(token)
                    state = .authenticated
                }
                return
            } catch let error as YTMusicError {
                switch error {
                case .authCancelled:
                    // User denied - stop polling
                    await MainActor.run { state = .failed(.authDenied) }
                    return
                case .authCodeExpired:
                    // Code expired - stop polling
                    await MainActor.run { state = .failed(.authCodeExpired) }
                    return
                default:
                    // Other errors (like "authorization_pending") - continue polling
                    continue
                }
            } catch {
                logger.error("Unexpected error during polling: \(error)")
                continue
            }
        }

        // Deadline reached
        await MainActor.run { state = .failed(.authCodeExpired) }
    }

    /// Request access token using device code
    private func requestToken(deviceCode: String) async throws -> TokenResponse {
        var request = URLRequest(url: OAuth.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "client_id": OAuth.clientID,
            "client_secret": OAuth.clientSecret,
            "device_code": deviceCode,
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
        ]
        request.httpBody = body.urlEncodedString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw YTMusicError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            // Check for known error responses
            if let errorResponse = try? JSONDecoder().decode(OAuthErrorResponse.self, from: data) {
                switch errorResponse.error {
                case "authorization_pending":
                    // User hasn't authorized yet - this is expected during polling
                    throw YTMusicError.unknown(message: "authorization_pending")
                case "slow_down":
                    // Need to slow down polling - handled by interval
                    throw YTMusicError.unknown(message: "slow_down")
                case "access_denied":
                    throw YTMusicError.authDenied
                case "expired_token":
                    throw YTMusicError.authCodeExpired
                default:
                    throw YTMusicError.httpError(
                        statusCode: httpResponse.statusCode,
                        message: errorResponse.errorDescription
                    )
                }
            }

            throw YTMusicError.httpError(statusCode: httpResponse.statusCode, message: nil)
        }

        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }

    /// Refresh access token using refresh token
    private func requestTokenRefresh(refreshToken: String) async throws -> TokenResponse {
        var request = URLRequest(url: OAuth.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "client_id": OAuth.clientID,
            "client_secret": OAuth.clientSecret,
            "refresh_token": refreshToken,
            "grant_type": "refresh_token",
        ]
        request.httpBody = body.urlEncodedString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw YTMusicError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            throw YTMusicError.authTokenRefreshFailed
        }

        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }

    /// Store token response in keychain
    private func storeToken(_ token: TokenResponse) {
        keychain.set(token.accessToken, forKey: Keys.accessToken)

        if let refreshToken = token.refreshToken {
            keychain.set(refreshToken, forKey: Keys.refreshToken)
        }

        let expirationDate = Date().addingTimeInterval(TimeInterval(token.expiresIn))
        keychain.set(String(expirationDate.timeIntervalSince1970), forKey: Keys.tokenExpiration)
    }
}

// MARK: - Dictionary Extension for URL Encoding

private extension Dictionary where Key == String, Value == String {
    var urlEncodedString: String {
        map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
    }
}
