# Reddit Launch Announcement for Reefy

## Pre-Posting Research Summary

**Sources Found:**
- [Swiftfin tvOS - Status Update (Discussion #1294)](https://github.com/jellyfin/Swiftfin/discussions/1294)
  - Started: October 29, 2024
  - Last update: January 12, 2026
  - Status: tvOS still not ready for TestFlight
  - Key quote: "we're all people, with other commitments, so plans/timelines can change rapidly"
  - No firm release date committed

- [State of the Fin 2026-01-06 Blog Post](https://jellyfin.org/posts/state-of-the-fin-2026-01-06/)
  - Published: January 6, 2026
  - Created "tvOS Resync" milestone
  - No timeline provided
  - tvOS development tracked separately from iOS releases

**Key Validation:**
These sources support the claim that tvOS support wasn't moving forward. The project has been stuck in development since October 2024 with no TestFlight and no committed timeline.

---

## Version 1: Straightforward & Community-Focused (RECOMMENDED)

### Title
**Built a tvOS Jellyfin client (Swiftfin fork) - available now on App Store**

### Body

```markdown
I wanted a tvOS-focused Jellyfin client, so I forked Swiftfin and built one. It's called Reefy and it's available now on the App Store.

**What it is:**

Reefy - tvOS-only Jellyfin client. Fork of Swiftfin. Same MPL 2.0 license. Full source on GitHub. Not affiliated with Jellyfin or Swiftfin.

**About pricing:**

$8.99 on the App Store. Here's why:

- Source code is free (MPL 2.0, same as Swiftfin)
- $8.99 covers App Store fees ($99/year) and commits me to ongoing support
- **Want to try it first? DM me for a promo code.**

**What it includes:**
- tvOS 18 Liquid Glass transport bar (tvOS 17 fallback)
- Redesigned playback controls for Apple TV remote
- Fixed navigation bugs and memory leaks from the fork
- VLC-based playback (from Swiftfin)

**Why a fork?**

I wanted to focus on tvOS-specific development. Long term, I want to tackle things like proper HDR decoding - complex projects that are easier to explore in a tvOS-only client.

**Built on:**

Swiftfin and Jellyfin. The Swiftfin team built the foundation. This is a continuation of that work with a tvOS-only focus.

**Links:**
- App Store: Search "Reefy Media Player" on Apple TV ($8.99 one-time)
- Source: [github.com/jmhunter83/reefy](https://github.com/jmhunter83/reefy) (free, MPL 2.0)
- Available in 175 countries worldwide

Feedback welcome.
```

**Character count:** ~1,498 characters

---

## Version 2: Ultra-Direct

### Title
**Reefy: tvOS-only Jellyfin client (Swiftfin fork) now on App Store**

### Body

```markdown
**Context:** Swiftfin tvOS has been in development since October 2024 - over a year. No TestFlight. No committed timeline ([source](https://github.com/jellyfin/Swiftfin/discussions/1294)). Volunteer team is working on it, but tvOS users needed something now. So I forked it.

**What it is:**
- Reefy: tvOS-only Jellyfin client
- $8.99 on App Store, source is free (github.com/jmhunter83/reefy, MPL 2.0)
- Not affiliated with Jellyfin or Swiftfin

**Why charge?**
- $99/year App Store fees
- Commits me to support and updates
- Source is free if you want to build it
- **DM for promo code if you want to try it first**

**What's different:**
- tvOS 18 Liquid Glass effects
- Redesigned playback controls
- Fixed navigation bugs and memory leaks
- Available today

**Credit:**
Built on Swiftfin's foundation. Swiftfin team did the hard work. This just serves people who need it now.

Links:
- App Store: Search "Reefy Media Player" on Apple TV ($8.99, 175 countries)
- Source: [github.com/jmhunter83/reefy](https://github.com/jmhunter83/reefy) (free, MPL 2.0)

Feedback welcome.
```

**Character count:** ~929 characters

---

## Response Templates

### "Why not contribute to Swiftfin?"

> Considered it. But tvOS has been stuck since October 2024 - over a year now. No TestFlight. No timeline. They're focused on long-term cross-platform compatibility, which is valid but slower. People needed something today.

> Long term, I want to explore tvOS-specific improvements that are harder in a multi-platform client. Having a tvOS-only fork makes those experiments possible.

### "Is this fragmenting the community?"

> Don't think so. Swiftfin tvOS isn't publicly available. No TestFlight, no App Store release. This fills that gap. When Swiftfin tvOS eventually re-launches, users will have choices. That's healthy. They're focused on long-term cross-platform compatibility. I want to explore tvOS-specific improvements that are harder to tackle in a multi-platform client. Different approaches can serve different needs.

### "You're charging for FOSS work?"

> Yes. Source is free (MPL 2.0, same as Swiftfin). App Store version covers my time and the $99/year Apple fee. If you don't like that, build it from source or wait for Swiftfin's eventual release.

### "This is just profiting off others' work"

> The license permits it. I'm not hiding the fork relationship - it's in the README and App Store listing. I've tried to be transparent about what's mine vs. inherited. Open to feedback if you think I should handle it differently.

### "Why not just donate to Jellyfin/Swiftfin instead?"

> People should support those projects. They're the foundation. This is different - a tvOS fork with immediate availability and active support. Different timelines, different needs.

### "Make it free"

> The $8.99 commits me to support and updates. Covers the $99/year Apple fee. Source is free at github.com/jmhunter83/reefy if you want to build it yourself. Happy to send a promo code if you want to try it first - DM me.

### "When people ask for promo codes"

> Sent you a DM.

*(Be generous with codes)*

### General criticism

> Fair point. Still learning. Thanks for the feedback.

---

## Handling Backlash

**If comments turn negative:**
- Don't get defensive
- Acknowledge valid points
- Remind them source is free
- Point to Swiftfin as the eventual alternative
- If toxic, stop engaging

**Don't:**
- Compare prices to other apps
- Say "it's worth it" or "just $8.99"
- Criticize Swiftfin maintainers
- Argue about FOSS philosophy
- Claim Reefy is "better" (say "available now")

**Do:**
- Credit Swiftfin as the foundation
- Stick to facts (dev status, timeline)
- Acknowledge volunteer work is hard
- Give out promo codes generously
- Accept criticism

---

## Target Subreddits

### r/appletv (Primary)
**Why:** Active Apple TV community, relevant audience, receptive to new apps

**Approach:** Focus on "modern tvOS client", less on Swiftfin situation

**Timing:** High-traffic hours (EST morning/evening)

### r/JellyfinCommunity (Secondary)
**Why:** Community-run, more receptive than official r/jellyfin

**Approach:** Emphasize serving tvOS users, credit Swiftfin

**Note:** Expect more pushback about forking/pricing

### r/jellyfin (SKIP)
**Why:** Read-only since June 2023 (moved to forum.jellyfin.org)

**Alternative:** forum.jellyfin.org - expect scrutiny

---

## Pre-Post Checklist

- [ ] GitHub repo is public and clearly states it's a fork
- [ ] README.md properly credits Swiftfin and Jellyfin
- [ ] App Store listing mentions it's a fork of Swiftfin
- [ ] Have promo codes ready to distribute
- [ ] Screenshot App Store listing to include in post
- [ ] Test all links in the post
- [ ] Read subreddit rules for self-promotion

---

## Post-Launch Monitoring

**First 24 hours:**
- Check every 2-3 hours for comments
- Respond to questions quickly and humbly
- Distribute promo codes generously
- Thank people for constructive feedback

**Watch for:**
- Swiftfin maintainers commenting (be EXTREMELY respectful)
- Jellyfin team members (acknowledge their work)
- FOSS philosophy debates (don't engage deeply)
- Feature requests (note them for future updates)

**Metrics to track:**
- Comment sentiment (positive/neutral/negative)
- Promo code requests
- Direct messages
- Cross-posts to other communities
- GitHub stars/traffic spikes

---

## Sources for Reference in Discussions

When defending your claims, cite these:

1. **Swiftfin tvOS Status** - https://github.com/jellyfin/Swiftfin/discussions/1294
   - Started Oct 29, 2024
   - Last updated Jan 12, 2026
   - No TestFlight available
   - No firm timeline

2. **State of the Fin Blog** - https://jellyfin.org/posts/state-of-the-fin-2026-01-06/
   - Published Jan 6, 2026
   - Created "tvOS Resync" milestone
   - No timeline provided

3. **Swiftfin December Dev Blog** - https://github.com/jellyfin/Swiftfin/discussions/1832
   - Confirms volunteer-driven development
   - Acknowledges timeline uncertainty
