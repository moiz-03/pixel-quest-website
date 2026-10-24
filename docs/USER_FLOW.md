# User Flow — Pixel Quest Website

Two primary flows are defined: **the visitor's journey** (marketing) and **the existing user's journey** (changelog check). Both are optimized for speed and minimal friction.

---

## 1. Visitor Arrival $\rightarrow$ Install (Primary Flow)

```text
┌────────────────────────────┐
│     External Referral      │
│  (Reddit, X, Discord, etc) │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐
│         index.html         │
│  Hero + Features + Shots   │
│       + Download CTA       │
└──────────────┬─────────────┘
               │
   ┌───────────┼───────────┐
   ▼           ▼           ▼
Downloads   Reads FAQ   Reads Features
Directly       │           │
   │           ▼           │
   │      Privacy/Terms    │
   │           │           │
   └───────────┴───────────┘
               │
               ▼
┌────────────────────────────┐
│       download.html        │
│  Install Steps + Checksum  │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐
│        APK Download        │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐
│     OS Install Prompt      │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────┐
│      Pixel Quest App       │
└────────────────────────────┘
```

- **Total clicks from landing to APK:** 2 (landing $\rightarrow$ download page $\rightarrow$ download button).
- **Time budget:** $\le 60\text{ seconds}$.

---

## 2. Landing Page Layout Structure

| Zone | Content | Section Name | Desktop Padding |
|---|---|---|---|
| **Nav** (sticky) | Logo · What you can track · Download · FAQ · GitHub | — | — |
| **Hero** | Headline · Tagline · 1 CTA · Caption · Mockup · Stats strip | — | 120 / 96 px |
| **Features** | 6 Cards (Quests, XP, Streaks, Freezes, Reminders, Offline) | *What you can track* | 96 px |
| **Screenshots** | 4–6 phone frames, horizontal scroll | *A look inside* | 64 px |
| **How it Works** | 3-step timeline | *One quest a day* | 80 px |
| **Tiers Preview** | 7 badges | *Climb the ranks* | 96 px |
| **Download CTA** | Large button + version + size + checksum | *Get the APK* | 128 px |
| **FAQ Teaser** | 3 questions + link to full FAQ | *Before you install* | 80 px |
| **Footer** | Privacy · Terms · Changelog · GitHub · Contact | — | 64 px |

---

## 3. FAQ Visitor (Secondary Flow)

```text
index.html (FAQ Teaser)
    │
    ▼
faq.html ───► Reads Accordion ───► download.html
    │
    └───► Reads privacy.html ───► back to faq.html
```

*Rule:* Accordion responses must be concise ($\le 3$ sentences). Complex details belong on `features.html`.

---

## 4. Existing User Flow (Updates)

```text
Existing User
    │
    ▼
index.html
    │
    ▼
Nav ───► changelog.html
            │
            ▼
   Clicks "Download Latest" ───► download.html ───► Install Update
```

**Changelog Requirements:**
- Reverse-chronological order.
- Dated version headers.
- User-facing descriptions only.
- $\le 10$ bullets per release.

---

## 5. In-App Context Alignment

The website marketing copy reflects the following internal onboarding state:

```text
App Launch ──► Splash ──► Check Auth State
                            ├── No Account ──► [LOGIN] / [REGISTER]
                            └── Auth Valid ──► Dashboard UI
```

**Website Summary Translation:** "Create an account, add your first quest, check it off each day."

---

## 6. Outbound Links Specification

| From | To | Type |
|---|---|---|
| Nav "GitHub" | `https://github.com/<user>/pixel-quest` | External (`target="_blank"`) |
| Footer "Contact" | `mailto:hello@<domain>` | Mailto |
| Footer "Privacy" | `/privacy.html` | Internal |
| Footer "Terms" | `/terms.html` | Internal |
| Footer "Changelog" | `/changelog.html` | Internal |
| `download.html` | GitHub Releases binary (`https://github.com/.../releases/...`) | Direct Binary Download |
| `features.html` | `/download.html` | Internal CTA |
| `faq.html` | `/download.html` | Internal CTA |
| Privacy | `/terms.html` | Internal Link |

*Note:* All external links use `rel="noopener noreferrer"`.

---

## 7. Error Handling Strategy

| Situation | Behavior |
|---|---|
| APK Missing | `download.html` shows "Download temporarily unavailable" message (no 404). |
| Invalid Route | Serves custom `404.html`. |
| Disabled JS | Page functions statically. Accordions open by default. Nav displays inline. |
| Slow Network | System monospace fallback via `font-display: swap`. |
| Reduced Motion | CSS transitions and animations disabled globally. |

---

## 8. Visitor Exit Points

- **Hero Bounce:** Acceptable loss.
- **GitHub Exit:** Converted to open-source project viewer.
- **FAQ Bounce:** Signals necessary refinement of copy.
- **Uninstalled Download:** Signals trust/security messaging needs improvement.

---

## 9. Layout Adjustments Across Screen Sizes

| Element | Mobile ($\le 767\text{px}$) | Desktop ($\ge 1024\text{px}$) |
|---|---|---|
| Nav | Hamburger drawer | Horizontal inline |
| Hero | Single-column stacked | Two-column side-by-side |
| Features | 1 column | 3 columns |
| Screenshots | Horizontal touch scroll | Horizontal trackpad/mouse scroll |
| Rank Tiers | 2 per row | 7 inline |

---

## 10. Acceptance Criteria

A new visitor can:
1. Land on the site via any source link.
2. Understand core app capability within $\le 20\text{ seconds}$.
3. Navigate to the APK download in $\le 2\text{ clicks}$.
4. Complete installation instructions in $\le 3\text{ minutes}$.
5. Access legal pages from the main footer in $1\text{ click}$.
6. Verify the published SHA-256 binary hash.