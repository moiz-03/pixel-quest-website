
---

## File 4 of 9 — `DESIGN.md`

# Design — Pixel Quest Website

The website **must** visually match the mobile app, but be its own thing.
Two rules separate good design from generic AI output:

1. **Chrome uses three colors.** Mint (action) · Ink (grayscale) · Gold (accent).
2. **Sections are not the same shape twice.** Every section reuses the
   tokens but not the layout skeleton of its neighbor.

The authoritative source of truth for colors, sizes, and text styles is
the Flutter app (`lib/theme/*`). Those values are copied into
`assets/css/tokens.css`, but the site may **narrow** the palette — never
widen it.

---

## 1. Color

### 1.1 Chrome palette (three colors, hard rule)

```css
:root {
  /* 1 · Ink — every surface, border, shadow, and body-text tone */
  --ink-0:   #0B0F1A;      /* page background */
  --ink-1:   #131A33;      /* card background */
  --ink-2:   #1E2A45;      /* elevated card */
  --ink-3:   #25324F;      /* border */
  --ink-fg:  #FFFFFF;      /* foreground on ink */
  --ink-fg2: #8FA3BF;      /* secondary text */
  --ink-fg3: #5C6E8C;      /* muted text */

  /* 2 · Mint — the one action color */
  --mint:      #00E5A0;    /* primary CTA, focus rings */
  --mint-dark: #00B37A;    /* hover */

  /* 3 · Gold — single accent, earned not decorated */
  --gold:      #FFC542;    /* tier-up, XP coins, one hero caption */
}
Rule: nav, buttons, borders, shadows, backgrounds, and text use
only --ink-*, --mint, --gold. No fourth color appears in chrome.

### 1.2 Content colors (inside cards only)
The following colors come from the app and appear only inside
content cards — the tier preview row, the category legend, and the
features.html tier table. They are illustrations, not UI, and do not
appear in nav, buttons, or section chrome.
```css
/* Content-only fills. Never used for buttons, borders, or links. */
--tier-novice:   #8FA3BF;
--tier-squire:   #CD7F32;
--tier-knight:   #7BA7D9;
--tier-champion: #FFC542;
--tier-hero:     #00E5A0;
--tier-legend:   #9D6BFF;
--tier-mythic:   #FF4D8F;

--cat-health:    #3AA0FF;
--cat-fitness:   #FF4D8F;
--cat-self:      #FF4D8F;
--cat-skills:    #9D6BFF;

--state-error:   #E74C3C;   /* form errors only */
```

### 1.3 Removed from the old tokens (do not reintroduce)
--gradient-primary — no gradient buttons, ever.

--gradient-background — the page has one flat ink background; no gradients.

--glow-gold — only --glow-mint survives (single shadow accent).

--color-badge-cyan — unused in app; not present on site.

### 1.4 Section backgrounds
The whole page sits on --ink-0.

No alternating #f5f5f5 / #fafafa rhythm. Sections are separated by spacing, not color. When a section needs a raised feel, use --ink-1 on a card inside the section, not on the section itself.

### 1.5 Shadows (two types, hard limit)
```css
:root {
  --shadow-soft:  0 8px 18px rgba(0, 0, 0, 0.35);  /* elevation */
  --glow-mint:    0 0 24px rgba(0, 229, 160, 0.35); /* CTA emphasis */
}
```

Only two elements carry --shadow-soft on any page: the phone mockup
in the hero and the APK card on download.html. Only one element
carries --glow-mint: the primary Download button. If a card feels
flat, add a border (--ink-3), not a shadow.
## 2. Typography
### 2.1 Two families
```css
:root {
  /* Display — headings, nav, labels, buttons only. Pixel identity. */
  --font-display: 'Press Start 2P', ui-monospace, monospace;

  /* Body — all paragraphs ≥ 1 sentence. Readability first. */
  --font-body: ui-monospace, 'SFMono-Regular', Menlo, Consolas,
               'Liberation Mono', monospace;
}
```

Why two families. Press Start 2P is 2× wider than a standard font at
the same size. At 10 px (the app's body size) it is readable for a
short quest title; at 14 px it is not readable for a paragraph. Legal
pages and FAQ answers must be legible. The pixel font stays for
everything that carries identity — the h1, the section titles, the
button labels, the tier names. The body family carries information.

This also makes the heading/body check pass on the family axis, not
just the spacing axis.
### 2.2 Type scale — deliberate, not uniform
| Role | Size | Line-height | Letter-spacing | Family |
|---|---:|---:|---:|---|
| .t-display | 32 px | 1.15 | 3 px | display |
| .t-h1 | 24 px | 1.2 | 2 px | display |
| .t-h2 | 16 px | 1.25 | 1.5 px | display |
| .t-h3 | 12 px | 1.3 | 1 px | display |
| .t-body | 14 px | 1.7 | 0.2 px | body |
| .t-small | 13 px | 1.6 | 0.2 px | body |
| .t-caption | 11 px | 1.5 | 0.2 px | body |
| .t-label | 10 px | 1.4 | 1.2 px | display |
Contrast ratio: display 32 → h1 24 → h2 16 → h3 12 → body 14 → caption 11. This is deliberately not a uniform increment — h1:h2 = 1.5×, body:caption = 1.3×. The pixel font makes each step visually wider than its nominal ratio, so this scale reads clearly at every level.

Line-height: headings 1.15–1.3, body 1.5–1.7. Never the same.

Letter-spacing: mandatory on .t-display, .t-h1, .t-h2, and .t-label. Never rely on the browser default.
### 2.3 Mobile sizes
On viewports < 480 px, drop display to 24 px and h1 to 20 px. Do not scale body below 14 px — legibility trumps density.
## 3. Spacing
```css
:root {
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 24px;
  --space-6: 32px;
  --space-7: 48px;
  --space-8: 64px;
  --space-9: 96px;
}
```

Section spacing is not uniform. Each section gets the padding its content needs:

| Section | Vertical padding (desktop) |
|---|---|
| Hero | 120 px top, 96 px bottom |
| What you can track | 96 px |
| A look inside | 64 px |
| One quest a day | 80 px |
| Climb the ranks | 96 px |
| Get the APK | 128 px (largest, deliberate) |
| Before you install | 80 px |
| Footer | 64 px |
The variety is a design decision, not an accident — the largest gap is at the CTA because it is the conversion point.
## 4. Radii
:root {
  --radius-sm:   6px;    /* badges, tags, checkbox */
  --radius-md:   12px;   /* cards, buttons, inputs */
  --radius-lg:   20px;   /* sheets, modals */
  --radius-pill: 999px;  /* nav pill, tier chip */
}
## 5. Layout — hero redesign
The old hero was: full-height + big title + tagline + 2 CTAs + phone mockup. That is the generic template. Replace it with an asymmetric, single-CTA, single-column-offset composition:
```text
┌──────────────────────────────────────────────────────────────┐
│ [logo]  What you can track  Download  FAQ  GitHub  (sticky) │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  SMALL                        ┌───────────────────────┐      │
│  HABITS                       │                       │      │
│  BIG                          │    [phone mockup]     │      │
│  ADVENTURES                   │                       │      │
│                               │   (rotated -3°,       │      │
│  One sentence tagline.        │    offset from grid)  │      │
│                               └───────────────────────┘      │
│  [↓ Download APK]                                            │
│  v1.0.0 · 12 MB · Android 8+                                 │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│  Offline-first   ·   No account needed   ·   Free forever   │
└──────────────────────────────────────────────────────────────┘
```
What makes this different from the generic template:

Single CTA, not two. GitHub lives in the nav only.

Left-aligned, not centered. Body text and headings both left-align.

Not fullscreen — min-height: 560px on desktop, not 100vh.

Stats strip at the bottom of the hero (Offline-first · No account · Free) — a small footer of facts, not a CTA.

Asymmetric phone mockup — offset to the right, slightly rotated, breaking the grid.

Vertical budget: hero is 560–640 px on desktop, 480–560 px on mobile. The first viewport on iPhone SE (667 px height) shows the whole hero plus the top of the stats strip. The visitor sees everything before scrolling.
## 6. Body text alignment
All body copy is left-aligned. No text-align: center on paragraphs.

Page titles on privacy.html, terms.html, changelog.html may center only the <h1> — everything below is left.

Section headers (<h2>) are left-aligned with a small tick mark ▸ in --mint as a visual rhythm cue, e.g.:

▸ What you can track

Never center two-line body paragraphs. If a line breaks, that's a sign it should be shorter.
## 7. Section names — concrete, not abstract
| Old (abstract) | New (concrete) |
|---|---|
| Features | What you can track |
| How it works | One quest a day |
| Tiers preview | Climb the ranks |
| Download CTA | Get the APK |
| FAQ teaser | Before you install |
Every heading must be a concrete noun phrase — something the reader can picture. "Features" is abstract; "What you can track" is not.
## 8. Buttons
### 8.1 Primary
```css
.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  min-height: 54px;                 /* touch target */
  padding: 0 var(--space-5);
  border: none;
  border-radius: var(--radius-md);
  background: var(--mint);          /* solid — no gradient */
  color: var(--ink-0);
  font-family: var(--font-display);
  font-size: 12px;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  cursor: pointer;
  box-shadow: var(--glow-mint);
  transition: background-color 120ms ease-out, transform 80ms ease-out;
}
```

.btn-primary:hover  { background: var(--mint-dark); }
.btn-primary:active { transform: translateY(1px); }
.btn-primary:focus-visible {
  outline: 3px solid var(--mint);
  outline-offset: 3px;
}
### 8.2 Secondary (outlined)
.btn-secondary {
  min-height: 44px;
  padding: 0 var(--space-4);
  background: transparent;
  color: var(--mint);
  border: 1.5px solid var(--mint);
  border-radius: var(--radius-md);
  font-family: var(--font-display);
  font-size: 11px;
  letter-spacing: 1px;
  text-transform: uppercase;
}
### 8.3 Link-style
Nav-only. No underline unless hovered. Focus ring always visible.

### 8.4 Rules
One .btn-primary per viewport. If two are visible at once, one is wrong.

Every button is ≥ 44 × 44 px.

Button labels are specific ("Download APK", "Read the changelog") — never "Learn more", never "Click here".
## 9. Cards
```css
.card {
  background: var(--ink-1);
  border: 1px solid var(--ink-3);
  border-radius: var(--radius-md);
  padding: var(--space-5);
  /* no box-shadow — hover reveals a mint border, not a shadow */
}
```

.card:hover { border-color: var(--mint); }
Cards do not have shadows. Shadows are reserved for the two allowed types (hero mockup, APK card).
## 10. Iconography
Inline SVG from @pixelarticons/svg.

16 px inline (nav, inline text), 22 px buttons, 30 px feature cards, 44 px hero.

Icon color: currentColor — inherits from the parent text color.

Never emoji. Never Unicode symbol as an icon.
## 11. Motion
```css
:root {
  --dur-fast:   120ms;
  --dur-std:    220ms;
  --dur-slow:   400ms;
  --ease-out:   cubic-bezier(0, 0, 0.2, 1);
  --ease-back:  cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

Allowed: opacity, transform, background-color, border-color.

Forbidden: width, height, top/left, margin transitions.

Non-essential motion is wrapped in @media (prefers-reduced-motion: no-preference).

No scroll-triggered entrance animations. Content is visible immediately; animation is limited to hover/focus feedback.
## 12. Responsive breakpoints
/* Mobile-first. Only two breakpoints. */
@media (min-width: 768px)  { /* tablet */ }
@media (min-width: 1024px) { /* desktop */ }
| Element | Mobile | Tablet | Desktop |
|---|---|---|---|
| Nav | Hamburger → drawer | Inline (compact) | Inline |
| Hero | Stacked; mockup below CTA | 2 columns | 2 columns, offset mockup |
| What you can track | 1 column | 2 columns | 3 columns |
| A look inside | Horizontal scroll | Horizontal scroll | Horizontal scroll |
| Climb the ranks | 2 per row | 3 per row | 7 in one row |
| Body copy | Left | Left | Left |
## 13. What the page must not do
No hero with two primary CTAs.

No fullscreen hero (100vh).

No purple-to-blue gradient anywhere.

No gradient buttons.

No alternating dark/light section rhythm.

No box-shadow on cards, inputs, or section containers.

No centered body paragraphs.

No "Learn more" CTAs.

No abstract section headings ("Features", "Benefits", "Solutions").

No emoji icons.

No placeholder gradient boxes.

No more than two shadow types total.
## 14. Reference composition
Hero (desktop, min-height: 560px):
```text
┌──────────────────────────────────────────────────────────────┐
│ [logo]    What you can track   Download   FAQ   GitHub       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  SMALL HABITS                          ┌──────────────┐     │
│  BIG ADVENTURES                        │              │     │
│  ───────────────                       │  screenshot  │     │
│  One sentence tagline here.            │  (rotated    │     │
│                                        │   -3°)       │     │
│  ┌────────────────┐                    │              │     │
│  │ ↓ Download APK │                    └──────────────┘     │
│  └────────────────┘                                          │
│  v1.0.0 · 12 MB · Android 8+                                 │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│  Offline-first   ·   No account needed   ·   Free forever   │
└──────────────────────────────────────────────────────────────┘
```
Rules of thumb:

One primary button per viewport.

Headings left-aligned with the mint ▸ tick.

Only one element per page carries --shadow-soft (mockup).

Only one element per page carries --glow-mint (Download CTA).

Every section header is a concrete noun phrase.
