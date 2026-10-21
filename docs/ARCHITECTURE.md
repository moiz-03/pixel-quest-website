# Architecture — Pixel Quest Website

> Companion site to the Pixel Quest mobile app. Presents features, screenshots,
> and the APK download. **No user sign-in. No backend. No cookies.**

## Two projects, one brand

| | Mobile app (existing) | Website (this project) |
|---|---|---|
| Runtime | Flutter (Dart) | Static HTML/CSS |
| Host | App stores (later) | Firebase Hosting / Netlify / GitHub Pages |
| Backend | Firebase Auth + Firestore | **None** — no server, no API |
| Auth | Email + password | **None** — no accounts |
| Data | Per-user in Firestore | Content baked into HTML |
| Users | Solo habit trackers | Visitors evaluating the app |

The website shares **visual design tokens** with the app (colors, spacing, typography) so a user who lands on the site and then downloads the APK has zero visual discontinuity.

## High-level layout

```text

pixel-quest-web/
├── public/
│ ├── index.html # Landing page (hero, features, screenshots, download)
│ ├── download.html # APK download landing + install instructions
│ ├── features.html # Deeper dive on quests, XP, streaks, freezes
│ ├── faq.html # FAQ accordion
│ ├── privacy.html # Privacy policy (hosts the URL referenced by the app)
│ ├── terms.html # Terms of service (hosts the URL referenced by the app)
│ ├── changelog.html # Version history
│ └── 404.html # Custom not-found
│
├── assets/
│ ├── css/
│ │ ├── tokens.css # Design tokens — the SINGLE SOURCE OF TRUTH
│ │ ├── base.css # Reset + typography + link styles
│ │ ├── layout.css # Container, grid, section spacing
│ │ └── components.css # Buttons, cards, badges, nav, footer
│ ├── js/
│ │ └── main.js # ~100 lines: mobile nav, FAQ accordion, theme persistence
│ ├── fonts/
│ │ └── PressStart2P-Regular.woff2 # Self-hosted — no Google Fonts CDN dependency
│ ├── img/
│ │ ├── logo.svg # Pixel gamepad icon (from SplashLogo)
│ │ ├── screenshots/ # 4–6 phone screenshots of the app
│ │ ├── og-preview.png # 1200×630 social preview
│ │ └── favicon.ico
│ └── downloads/
│ └── pixel-quest-v1.0.0.apk # The build artifact
│
├── docs/ # ← the 9 markdown files this pack produces
├── .gitignore
├── firebase.json # If hosted on Firebase Hosting
└── README.md # Build & deploy instructions
```

## Page structure (single-page-first)

`index.html` is a **long scrolling landing page**. Other pages are secondary:
```text

┌─ Nav (sticky, blurred backdrop)
│ [Logo] [What you can track] [Download] [FAQ] [GitHub]
├─ Hero
│ ┌─ Left column ─────────────┐ ┌─ Right column ───────────┐
│ │ "SMALL HABITS │ │ Phone mockup with │
│ │ BIG ADVENTURES" │ │ screenshot, offset │
│ │ (Press Start 2P, white) │ │ right, rotated -3° │
│ │ │ │ │
│ │ One-sentence tagline │ │ │
│ │ │ │ │
│ │ [↓ Download APK] │ │ │
│ │ v1.0.0 · 12 MB · Android 8+ │ │
│ └────────────────────────────┘ └──────────────────────────┘
│ Offline-first · No account needed · Free forever
├─ What you can track (6 cards in 3×2 grid)
│ Quests · XP & Levels · Streaks · Streak Freezes ·
│ Reminders · Offline-First
├─ A look inside (horizontal screenshot scroll)
├─ One quest a day (3-step timeline)
├─ Climb the ranks (7 tier badges: Novice → Mythic)
├─ Get the APK (large button + version + checksum)
├─ Before you install (FAQ teaser)
└─ Footer (links: Privacy, Terms, Changelog, GitHub, Contact)
```

## Where content lives

Content is **written directly in HTML** — no CMS, no build-time data fetching. Rationale:

- Page count is small (~7 pages).
- Content changes rarely.
- Zero attack surface (no CMS login, no DB).

If content ever outgrows hand-written HTML, migrate to **Astro** (not Next/React) — it keeps the output static.

## Relationship to the mobile app

| App asset | Website use |
|---|---|
| `lib/theme/app_colors.dart` | Narrowed to three chrome colors + content-only palette in `tokens.css` |
| `lib/theme/app_sizes.dart` | Copied into `tokens.css` — same spacing scale |
| `lib/theme/app_text_styles.dart` | Re-expressed as CSS classes; site uses two font families (display + body) |
| `assets/fonts/PressStart2P-Regular.ttf` | Converted to `.woff2` for the web |
| `AppUrls.terms` / `AppUrls.privacy` | Point at `https://<domain>/terms` and `/privacy` — **this site must host them** |
| Splash screen, home dashboard, stats | Screenshot for the "A look inside" section |

When a design token changes in the app (`AppColors.xpGreen`), it must change in `tokens.css` in the same commit. See `CODING_RULES.md § Design token synchronization`.

## Hosting topology

```text

Cloudflare / Netlify / Firebase Hosting (CDN)
│
└─▶ Static files: HTML, CSS, JS, images, .apk
│
└─ no origin server, no database, no auth, no cookies
```

## Non-goals

- No user accounts on the site.
- No live data from Firestore (would require auth anyway).
- No blog engine, no CMS, no server-side rendering.
- No APK auto-update mechanism — a new APK means a new static file + changelog entry.
