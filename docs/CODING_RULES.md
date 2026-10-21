# Coding Rules — Pixel Quest Website

Rules are not suggestions. Anything violating them should be fixed before merge.

## General

1. **Zero runtime dependencies on the client.** No CDN scripts. No Google Fonts. No analytics SDKs. If a feature requires a third-party library, justify it in the PR description.
2. **No build step required to run locally.** Opening `public/index.html` in a browser must work. Optional bundling is allowed for production if it produces the same behavior.
3. **Progressive enhancement.** Every page works with JavaScript disabled. JS may *add* (mobile nav, FAQ accordion), never *require*.
4. **No inline styles.** All styles live in CSS files under `assets/css/`.
5. **No inline scripts** except `<script type="application/ld+json">` for schema.org.

## HTML

- `<!DOCTYPE html>`, `<html lang="en">`, `<meta charset="utf-8">`.
- One `<h1>` per page.
- Every `<img>` has `alt` (empty `alt=""` for decorative).
- Every `<a>` with `target="_blank"` has `rel="noopener noreferrer"`.
- Use semantic elements (`<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`) — not `<div>` soup.
- Buttons that don't submit forms are `<button type="button">`.
- Form controls are `<label>`-associated, or have `aria-label`.
- File names: `kebab-case.html`.

## CSS

- **Mobile-first.** Base styles target 320px. `@media (min-width: 768px)` for tablet, `(min-width: 1024px)` for desktop.
- Class names: `kebab-case` with a semantic prefix where helpful — `.hero`, `.feature-card`, `.btn-primary`.
- **Never use `!important`** except for the two guarded cases: (a) overriding a user-agent stylesheet during a documented bug, (b) accessibility utilities (`.sr-only`, `.hidden-desktop`).
- Use CSS custom properties for every color, spacing, font size, and radius. See `DESIGN.md § Tokens`.
- No vendor prefixes except `-webkit-backdrop-filter` (Safari) and `-webkit-font-smoothing`.
- Prefer `gap` over `margin` for layout spacing.
- Do not write one-off media queries; use the two defined breakpoints.

## JavaScript

- **Vanilla ES2022, no build.** Modules via `<script type="module">`.
- Total JS budget: **≤ 8 KB unminified**, **≤ 3 KB gzipped**.
- No `eval`, no `new Function`, no `innerHTML` with untrusted data.
- Event listeners attached via `addEventListener`, never `onclick=""`.
- Clean up timers and listeners on `pagehide`.
- Zero JS on the privacy, terms, and changelog pages unless strictly necessary.

## Design-token discipline

1. **Chrome palette is exactly three colors**: mint, ink, gold. See `DESIGN.md § 1.1`.
2. **Content colors** (tier badges, category fills) may appear **only inside cards** — never in nav, buttons, borders, or section backgrounds.
3. **Exactly two shadow tokens** exist in the codebase (`--shadow-soft`, `--glow-mint`). If a new element needs emphasis, add a border — not a shadow.
4. **No gradients** anywhere — not on buttons, not on backgrounds, not on any element. The tokens file does not define any gradient variables.
5. **One primary button per viewport**. If you find yourself with two `.btn-primary` visible at once, one of them is `.btn-secondary`.

## Design token synchronization

`assets/css/tokens.css` mirrors `lib/theme/app_colors.dart` and `app_sizes.dart`.
Any change to a color or spacing token in the Flutter app **must** be reflected in `tokens.css` before the next website deploy. The reverse is forbidden — the app is the source of truth, the site narrows it.

The website build script verifies this:

```bash
#!/usr/bin/env bash
# tools/sync-tokens.sh — fails if tokens diverge
# Extracts `static const Color NAME = Color(0xFFHEX);` from app_colors.dart
# and compares against tokens.css. Diff must be empty.
```

## Accessibility
- Minimum contrast ratio: 4.5:1 for body text, 3:1 for large text. Test with Lighthouse → Accessibility.
- Keyboard-navigable. Every interactive element must be reachable via Tab, activatable via Enter, and dismissible via Escape (for modals/accordions).
- :focus-visible styling is mandatory on all interactive elements.
- prefers-reduced-motion: reduce disables non-essential transitions.

## Performance
- Lighthouse Performance ≥ 95 on mobile.
- Lighthouse Accessibility ≥ 100.
- Lighthouse Best Practices ≥ 100.
- Lighthouse SEO ≥ 100.
- Total page weight (landing) ≤ 400 KB including fonts, images, APK excluded.
- Fonts: only one file, PressStart2P-Regular.woff2, subset to latin + basic-latin, font-display: swap.

### File sizes

| Asset | Max size |
|---|---|
| Any HTML file | 80 KB |
| Any CSS file | 30 KB |
| Any JS file | 8 KB |
| Any screenshot | 250 KB (WebP, 750px wide, 2× for retina) |
| Hero image | 400 KB |
| APK | 80 MB (Play Store limit; recommended < 40 MB) |

## SEO
Unique <title> and <meta name="description"> per page (50–60 chars title, 150–160 chars description).

<link rel="canonical"> on every page.

sitemap.xml and robots.txt at site root.

OpenGraph + Twitter Card meta on every page. og-preview.png (1200×630).

Structured data: SoftwareApplication schema on index.html, FAQPage on faq.html.

Testing
Manual pass against TASKS.md acceptance criteria before every deploy.

Automated: pa11y (accessibility), html-validate (HTML), lighthouse-ci (perf + PWA + SEO), and linkcheck (no broken links) run in CI.

Any new page must be reachable from the nav or footer (no orphans).

Git
Conventional commits: feat:, fix:, docs:, chore:, perf:, a11y:, seo:.

One logical change per commit.

Commit messages are user-facing (published changelog is generated from them).

Explicitly forbidden
Analytics scripts of any kind — no Google Analytics, Plausible, Umami, etc. If metrics ever become important, use server-side access logs.

Ad networks.

Chat widgets (Intercom, Crisp, etc.).

Cookie banners (there are no cookies).

Auto-playing media with sound.

Modal popups within the first 5 seconds of page load.

Gradient buttons or gradient backgrounds.

A second primary CTA in the hero.

text-align: center on <p> elements.

A third box-shadow token (two is the maximum).

Emoji as icons.
