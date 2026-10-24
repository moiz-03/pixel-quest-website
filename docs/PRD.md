# Product Requirements Document — Pixel Quest Website

**Status:** Draft · **Version:** 1.0 · **Last updated:** 2026-10-21

---

## 1. Problem

Pixel Quest is a Flutter habit-tracking app with an unusual angle: it's a retro pixel-art RPG. There's no marketing site, and the `AppUrls.terms` / `AppUrls.privacy` constants point at `https://flutter.dev` — a placeholder.

To distribute the APK outside the Play Store (early access, beta testing, direct download), we need:

1. A public landing page that communicates the app's identity.
2. A stable URL for the APK download.
3. Hosted privacy policy and terms of service (currently placeholder).
4. Zero friction: **no account, no email, no cookie banner**.

---

## 2. Goals

| Goal | Success metric |
|---|---|
| Communicate the app's value in $\le 20$ seconds | Bounce rate $< 60\%$ |
| Make APK download obvious and 1 click | $\ge 40\%$ of visitors click Download |
| Match the app's visual identity | 0 reported "the app looks different" issues |
| Host legal pages the app can link to | `AppUrls.terms` / `AppUrls.privacy` point here |
| Be a fast, privacy-respecting site | Lighthouse 100/100/100/100 |

---

## 3. Non-goals

- **No user sign-in.** Not even "Sign in with Google" to sync data. The site has no user state.
- **No backend.** No server-side code, no database, no authentication service.
- **No PWA.** No service worker, no install prompt, no offline capability (the APK is the install).
- **No analytics.** No tracking scripts, no cookies, no fingerprinting.
- **No blog / CMS.** Content is written directly in HTML.
- **No forums, comments, or user-generated content.**
- **No push notifications from the site.**

---

## 4. Personas

### P1 — The curious visitor (primary)
- Arrives from a Reddit post, tweet, or friend's link.
- Doesn't know what Pixel Quest is.
- Decision to download or bounce takes $\le 20$ seconds.
- **Needs:** hero, one-liner, screenshots, clear download button.

### P2 — The referrer (secondary)
- Sharing the link in a group chat.
- Cares that the OG preview card looks good.
- **Needs:** valid OG tags, `og-preview.png`.

### P3 — The cautious installer (secondary)
- Wants the APK but wants to see the privacy policy first.
- **Needs:** visible footer link to Privacy + Terms, clearly legible and current.

### P4 — The existing user returning for the changelog
- Already has the app; checks for updates.
- **Needs:** a working `changelog.html` with version history.

---

## 5. User Stories & Acceptance Criteria

### US-01 · Landing page hero

> As P1, I see the app's name, tagline, and a single primary CTA above the fold.

**Acceptance:**
- Headline "SMALL HABITS BIG ADVENTURES" in Press Start 2P, `--ink-fg`, 32px.
- Under it, a single-sentence tagline ($\le 12$ words) in body font, `--ink-fg2`.
- **One primary CTA only**: `↓ Download APK` — primary mint, glow-mint, min-height 54px.
- Under the CTA: small caption `v1.0.0 · 12 MB · Android 8+`.
- **No GitHub button in the hero** — it lives in the nav only.
- Right side: phone mockup, offset right, rotated -3°, `--shadow-soft`.
- Below the fold-line: a stats strip — `Offline-first · No account needed · Free forever`.
- Hero `min-height: 560px` on desktop (not full-screen), left-aligned.
- No horizontal scroll at any width.

---

### US-02 · Download

> As P1, tapping Download gets me the APK with install instructions.

**Acceptance:**
- Clicking Download navigates to `download.html`.
- `download.html` shows: file name, version, size, SHA-256 checksum, install steps for Android 8+.
- APK is served with `Content-Type: application/vnd.android.package-archive` and `Content-Disposition: attachment`.
- File available via official GitHub Releases link (e.g. `https://github.com/moiz-03/pixel-quest-website/releases/download/...` to avoid Firebase Spark/free tier bandwidth limits).
- If the download cannot be reached, the page shows "Download temporarily unavailable".

---

### US-03 · What you can track

> As P1, I understand what the app actually does without installing it.

**Acceptance:**
- Six feature cards on `index.html`: Quests, XP & Levels, Streaks, Streak Freezes, Reminders, Offline-first.
- Each card: icon, title $\le 3$ words, one-sentence description.
- Each card links to `features.html#<anchor>`.

---

### US-04 · A look inside

> As P1, I see what the app looks like before downloading.

**Acceptance:**
- 4–6 phone screenshots in a horizontal scroll strip.
- Each is inside a phone-frame mockup.
- Screenshots use the app's real UI (captured from a dev build).
- WebP format, $\le 250\text{ KB}$ each, `loading="lazy"`.

---

### US-05 · Climb the ranks

> As P1, I understand there's a progression system.

**Acceptance:**
- Section titled "Climb the ranks" with 7 tier badges: NOVICE, SQUIRE, KNIGHT, CHAMPION, HERO, LEGEND, MYTHIC.
- Each badge shows icon + name + level range (`LEVELS 0–4`).
- Tier colors match `models/tier.dart`.

---

### US-06 · FAQ

> As P3, my common questions are answered.

**Acceptance:**
- On `faq.html` and mirrored at `index.html#faq`.
- Each question is an accordion (open/close with keyboard).
- At minimum:
  - Is Pixel Quest free?
  - Does it need an account?
  - Does it work offline?
  - Where is my data stored?
  - How do I delete my account?
  - Why isn't it on the Play Store yet?
  - How do I install an APK?
  - Is my data sent anywhere?

---

### US-07 · Privacy & Terms

> As P3, I can read the policies before installing.

**Acceptance:**
- `privacy.html` and `terms.html` are complete, dated, and readable.
- Both use the same design tokens (dark theme, pixel display font for headers, body font for prose).
- Footer on every page links to both.
- **The app must be updated so `AppUrls.terms` / `AppUrls.privacy` point at these URLs** — tracked as a separate ticket.

---

### US-08 · Changelog

> As P4, I can see what's changed since I installed.

**Acceptance:**
- `changelog.html` lists every release, newest first.
- Each entry has: version, date, $\le 10$ bullet points of user-facing changes.
- Format: `1.0.0 — 2026-10-21`.
- No marketing fluff — what changed, in plain English.

---

### US-09 · No-auth guarantee

> As any visitor, I am never asked to create an account, sign in, or accept cookies.

**Acceptance:**
- Zero `<form>` elements requesting credentials.
- Zero references to Firebase, Supabase, Auth0, or any auth provider in the client.
- No cookie-banner DOM anywhere.
- Network tab shows zero requests to third-party origins (except the CDN serving the site).

---

## 6. Content — Minimum Required

| Page | Required Sections |
|---|---|
| `index.html` | Hero · What you can track (6 cards) · A look inside · One quest a day · Climb the ranks · Get the APK · Before you install (FAQ teaser) · Footer |
| `download.html` | Hero · APK card (name/version/size/checksum) · Install instructions (Android 8+) · Troubleshooting (3 items) · Changelog link · Footer |
| `features.html` | Deep dive on each of the 6 features · Tiers table · XP curve table · Footer |
| `faq.html` | Accordion of $\ge 8$ questions · Footer |
| `privacy.html` | Data collection (none) · What stays on device · What goes to Firebase · Retention · User rights (delete account) · Contact |
| `terms.html` | License · Acceptable use · Disclaimers · Liability · Governing law · Contact |
| `changelog.html` | Reverse-chronological version history · Footer |
| `404.html` | "No quest here" pixel-art · Link home |

---

## 7. Design Constraints

Summary:
- Dark background (`#0B0F1A`), mint primary (`#00E5A0`), gold accent (`#FFC542`).
- Press Start 2P for headings, monospace for body — two families, not one.
- Three chrome colors, content colors confined to cards.
- 8pt spacing grid, radii 6/12/20/999.
- One primary button per viewport.

---

## 8. Performance Budget

| Metric | Budget |
|---|---|
| LCP (mobile 3G) | $\le 2.5\text{ s}$ |
| CLS | $< 0.05$ |
| INP | $< 100\text{ ms}$ |
| Total page weight (landing) | $\le 400\text{ KB}$ |
| JS size (gzipped) | $\le 3\text{ KB}$ |
| Lighthouse Perf | $\ge 95$ |
| Lighthouse A11y / BP / SEO | 100 |

---

## 9. Launch Checklist

- [ ] All 7 HTML pages live and linked
- [ ] APK release asset published on GitHub Releases (linked in `download.html`)
- [ ] `og-preview.png` renders correctly when sharing on X / Slack / Discord
- [ ] `sitemap.xml` and `robots.txt` in place
- [ ] `AppUrls.terms` and `AppUrls.privacy` in the **app** point at the site's URLs
- [ ] Custom 404 page
- [ ] Custom domain + HTTPS
- [ ] Zero third-party requests verified in DevTools
- [ ] Lighthouse run logged in the release PR
- [ ] Tested on: iOS Safari 16+, Android Chrome 110+, Firefox 110+, desktop Chrome/Safari/Firefox

---

## 10. Out of Scope (v1)

- Multi-language (i18n) — English only in v1.
- Light mode / theme toggle.
- Video trailer.
- Blog / news section.
- Newsletter signup.
- Comments or user feedback form (email link instead).
- Play Store / App Store button (not listed yet).
- Account-based download (e.g., "verified users only") — the whole point is zero friction.