# Tasks — Pixel Quest Website

Prioritized work breakdown. Checkboxes for tracking progress.

---

## Phase 0 — Repo setup (½ day)

- [ ] Create `pixel-quest-web/` repo (separate from the app repo, or `website/` subfolder — **decide before starting**)
- [ ] `.gitignore`: ignore `node_modules/`, `dist/`, `.DS_Store`
- [ ] `README.md`: how to open the site locally (`python3 -m http.server` in `public/`)
- [ ] `LICENSE` (MIT unless otherwise chosen)
- [ ] Copy the 9 docs (`ARCHITECTURE.md`, `CODING_RULES.md`, `DATA_MODEL.md`, `DESIGN.md`, `PRD.md`, `SECURITY.md`, `TASKS.md`, `TECH_STACK.md`, `USER_FLOW.md`) into `docs/`

**Done when:** `git clone && cd pixel-quest-web/public && python3 -m http.server` serves `index.html` from the app repo's splash preview.

---

## Phase 1 — Design tokens & shell (1 day)

### 1.1 Tokens (blocker for everything else)

- [ ] `assets/css/tokens.css` — copy from `DESIGN.md`
- [ ] `assets/css/base.css` — reset + `@font-face` + typography classes
- [ ] `assets/css/layout.css` — `.container`, `.section`, grid helpers
- [ ] `assets/fonts/PressStart2P-Regular.woff2` — subset from the app's `.ttf` via `pyftsubset`
- [ ] `tools/sync-tokens.sh` — CI check that `tokens.css` matches `app_colors.dart`

**Done when:** opening `tokens.css` in a browser renders a swatch page showing every color + spacing token.

### 1.2 Shell

- [ ] `index.html` skeleton with `<header>`, `<main>`, `<footer>`
- [ ] Nav component (`.nav`, mobile hamburger toggle)
- [ ] Footer component (links: Privacy, Terms, Changelog, GitHub, Contact)
- [ ] `assets/js/main.js` — nav toggle, `prefers-reduced-motion` respect

**Done when:** the shell looks identical to the app's splash on desktop and mobile (same background, same display font).

---

## Phase 2 — Landing page content (2 days)

### 2.1 Hero

- [ ] Hero section: PIXEL QUEST headline, one-sentence tagline, single Download CTA, small caption
- [ ] Phone mockup frame with first screenshot, offset right, rotated -3°
- [ ] Stats strip below: `Offline-first · No account needed · Free forever`
- [ ] Fits above the fold on iPhone SE (375×667)

### 2.2 What you can track

- [ ] 6 feature cards (icons, titles, one-liners, links to `features.html#anchor`)
- [ ] Responsive: 1 col $\rightarrow$ 2 cols $\rightarrow$ 3 cols

### 2.3 A look inside

- [ ] Capture 4–6 screenshots from a real dev build (dummy data, not real user data)
- [ ] Convert to WebP (`cwebp -q 85`), verify $\le 250\text{ KB}$ each
- [ ] Horizontal scroll strip with phone frames
- [ ] `loading="lazy"` and `alt` text

### 2.4 Climb the ranks

- [ ] 7 tier badges with correct colors, icons, level ranges
- [ ] Source data from `models/tier.dart` — do NOT retype, copy

### 2.5 Get the APK & Before you install

- [ ] Large Download button
- [ ] Version, file size, SHA-256 line
- [ ] FAQ teaser linking to `faq.html`

**Done when:** Lighthouse shows Perf $\ge 95$, A11y 100 on the landing page.

---

## Phase 3 — Supporting pages (2 days)

### 3.1 `download.html`

- [ ] APK card (name, version, date, size, SHA-256)
- [ ] Install instructions: enable unknown sources, tap APK, open
- [ ] Troubleshooting: "app not installed", "unknown source blocked", "Play Protect warning"
- [ ] Link to changelog

### 3.2 `features.html`

- [ ] Deep-dive on each of the 6 features
- [ ] XP curve table (levels 0, 1, 2, 5, 10, 25, 50, 100)
- [ ] Tier table (all 7 with flavor text)
- [ ] Category legend (4 categories with icons + colors)

### 3.3 `faq.html`

- [ ] 8+ accordion items (see PRD.md US-06)
- [ ] Keyboard-accessible (`<button>`, `aria-expanded`)
- [ ] Works with JS disabled (fallback: all items open)

### 3.4 `privacy.html` & `terms.html`

- [ ] Drafted by a human (legal prose, not Lorem)
- [ ] Date-stamped
- [ ] Contact email address
- [ ] **The app's `AppUrls.terms` and `AppUrls.privacy` must be updated** (ticket in app repo)

### 3.5 `changelog.html` & `404.html`

- [ ] `changelog.html` — one entry per release since 1.0.0
- [ ] `404.html` — pixel-art "no quest here" + link home

**Done when:** every page in the nav resolves, no 404s, and each page has unique `<title>` + meta description.

---

## Phase 4 — SEO & sharing (½ day)

- [ ] `og-preview.png` (1200×630) — designed in Figma or a pixel-art tool
- [ ] OG + Twitter meta tags on every page
- [ ] `sitemap.xml`
- [ ] `robots.txt` (`User-agent: *`, `Allow: /`, sitemap reference)
- [ ] JSON-LD `SoftwareApplication` on `index.html`
- [ ] JSON-LD `FAQPage` on `faq.html`
- [ ] `<link rel="canonical">` on every page
- [ ] Verified preview renders correctly in: X, Slack, Discord, Telegram

**Done when:** sharing the URL on X shows a valid preview card.

---

## Phase 5 — APK pipeline (1 day, once)

- [ ] Add a `tools/build-apk.sh` script to the **app** repo:
  - `flutter build apk --release --split-per-abi`
- [ ] Upload the release build to GitHub Releases (`pixel-quest-website/releases/tag/vX.Y.Z`)
- [ ] Link to the release asset in `download.html` with verified SHA-256
- [ ] `download.html` shows the checksum and install guide

**Done when:** The GitHub Releases download link resolves with valid headers and binary download.

---

## Phase 6 — Deploy (½ day)

**Pick one host:**
- [ ] **Firebase Hosting** (same project as app): `firebase init hosting` $\rightarrow$ `public/` $\rightarrow$ `firebase deploy`
- [ ] **Netlify**: `netlify.toml`, drag-drop or `netlify deploy --prod`
- [ ] **GitHub Pages**: enable in repo settings, no build step needed

**After choosing:**
- [ ] Custom domain configured
- [ ] HTTPS enforced (auto with all three)
- [ ] All security headers from `SECURITY.md` applied
- [ ] CSP header applied (verify with `curl -I`)
- [ ] `robots.txt` and `sitemap.xml` reachable
- [ ] Lighthouse final run (record in release PR)

**Done when:** `https://<domain>` serves the site from a clean browser with no console errors.

---

## Phase 7 — Post-launch (ongoing)

- [ ] Submit to Google Search Console (verify sitemap)
- [ ] Submit to Bing Webmaster Tools
- [ ] Add `og-preview.png` to the app's GitHub repo README (links to the site)
- [ ] Update app repo's `AppUrls.terms` / `AppUrls.privacy` and cut a new release
- [ ] Announce (Reddit, X, Discord, whichever applies)

---

## Cross-cutting: Known App Bugs

Pending issues found during audit (**do not block website launch**):
- [ ] **App Bug A** — foreground snooze overwrites daily reminder
- [ ] **App Bug B** — 3 permission dialogs block first launch
- [ ] **App Bug C** — App Check failure is fatal
- [ ] **App Bug D** — empty-payload guard missing in `handleAction`
- [ ] **App Bug E** — dead `AnimatedSwitcher` in Dashboard
- [ ] **App Bug F** — `retrySync` concurrency guard missing

*Website dependency:* "Is my data safe?" FAQ answer should state "we recommend keeping the app updated" rather than asserting Bug C is resolved.

---

## Release Blocker Checklist (App)

Before the site goes live:
- [ ] `AppUrls.terms` $\rightarrow$ site's `/terms`
- [ ] `AppUrls.privacy` $\rightarrow$ site's `/privacy`
- [ ] `iosBundleId` in `firebase_options.dart` is not `com.example.*`
- [ ] A release-signed APK exists (debug keystore is invalid for public distribution)
- [ ] `changelog.html` entry exists for the release version

---

## Total Estimate

- **Design + shell:** 1.5 days
- **Landing page:** 2 days
- **Supporting pages:** 2 days
- **SEO + share:** 0.5 days
- **APK pipeline:** 1 day
- **Deploy:** 0.5 day

**Total: ~7.5 days** (single developer at a steady pace with screenshots ready).