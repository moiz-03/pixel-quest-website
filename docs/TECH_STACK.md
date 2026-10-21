# Tech Stack — Pixel Quest

Two independent codebases live under the same brand.

---

## Part 1 — Mobile App (Existing)

| Layer | Choice | Version | Why |
|---|---|---|---|
| SDK | Flutter | Dart SDK `^3.13.4` | Cross-platform, pixel-perfect rendering |
| Language | Dart | 3.x | — |
| State | `provider` | `^6.1.5+1` | `ChangeNotifier` view-models |
| Auth | `firebase_auth` | `^5.3.1` | Email + password |
| DB | `cloud_firestore` | `^5.6.12` | Realtime streams + offline persistence |
| Core | `firebase_core` | `^3.6.0` | — |
| App Check | `firebase_app_check` | `^0.3.2+10` | Play Integrity / DeviceCheck |
| Local | `shared_preferences` | `^2.5.5` | Offline cache (JSON blobs) |
| Notifications | `flutter_local_notifications` | `^18.0.1` | Daily reminders with actions |
| Timezone | `timezone` + `flutter_timezone` | `^0.10.0` / `^5.1.1` | DST-safe scheduling |
| Permissions | `permission_handler` | `^13.0.2` | Notifications, exact alarm, battery |
| URLs | `url_launcher` | `^6.3.3` | Terms / Privacy external open |
| Font | Press Start 2P (bundled) | — | Only weight (400) ships |
| Icons | `pixelarticons` | `^0.4.0` | Retro icon set |

### Test Tooling

| Tool | Purpose |
|---|---|
| `flutter_test` | Widget + unit tests (608 tests, all green) |
| `integration_test` | Cold-start + register E2E |
| `firebase_auth_mocks` `^0.14.2` | FirebaseAuth fake |
| `fake_cloud_firestore` `^3.1.0` | Enforces the 500-write batch limit — makes the chunking tests real |
| `@firebase/rules-unit-testing` | Firestore rules integration tests (Node) |

### Build & Release

| Platform | Tooling |
|---|---|
| Android | Gradle 9.3.1, Kotlin DSL, AGP built-in |
| iOS | Xcode, Swift Package Manager for Firebase |
| Debug backend | Firebase Emulator Suite (Auth :9099, Firestore :8080) |
| Release backend | Production Firebase project `pixel-quest-aba36` |

---

## Part 2 — Website (New)

### Principles

1. **Static only.** No server, no database, no authentication.
2. **No build step.** Opening `public/index.html` locally must work.
3. **No runtime JS libraries.** Vanilla ES2022 only.
4. **No third-party origins** contacted at runtime. Zero analytics, zero CDNs, zero widget embeds.

---

### Core Stack

| Layer | Choice | Version | Why |
|---|---|---|---|
| Markup | HTML5 | — | — |
| Styling | Plain CSS (custom properties) | — | No Sass/Tailwind needed for a 7-page site |
| Scripting | Vanilla ES2022 | — | ~100 lines total |
| Font (display) | Press Start 2P (self-hosted `.woff2`) | — | Same font as the app; subset to `latin` |
| Font (body) | System monospace stack | — | Legibility for prose; pixel font only for headers |
| Icons | `@pixelarticons/svg` (inline SVG files) | latest | Same glyphs as the app's `pixelarticons` package |
| HTTP server (dev) | `python3 -m http.server` | stdlib | Zero install; any static server works |

---

### Hosting Options

| Host | Pros | Cons | Verdict |
|---|---|---|---|
| **Firebase Hosting** | Same project as the app, one CLI, generous free tier, automatic CDN + HTTPS, easy custom domain | Requires Firebase CLI | ✅ **Recommended** — already using Firebase |
| **Cloudflare Pages** | Fastest global CDN, free custom domain, excellent caching headers | New account to manage | Strong alternative |
| **Netlify** | Drag-and-drop deploy, `_headers` file for CSP | — | Good if you want the fastest setup |
| **GitHub Pages** | Free with the repo, zero config | No custom response headers $\rightarrow$ **cannot set CSP** | ❌ **Not recommended** |

**Decision:** Firebase Hosting. Unified project management, full header control via `firebase.json`.

---

### Optional devDependencies (CI Only)

| Package | Purpose |
|---|---|
| `html-validate` | HTML5 correctness |
| `pa11y` | Accessibility audit |
| `@lhci/cli` | Lighthouse CI |
| `linkinator` | Broken link detection |

---

### Explicitly Forbidden

| Rejected | Why |
|---|---|
| React / Vue / Svelte | Overkill for 7 static pages; adds a build step and JS bundle |
| Next.js / Nuxt | Requires a server runtime; PRD explicitly forbids |
| Tailwind CSS | Adds a build step; custom CSS properties are cleaner for this system |
| Bootstrap / Foundation | Mismatched aesthetics and color systems |
| jQuery | Unnecessary complexity |
| Google Fonts | External request, privacy concerns, CDN dependency |
| Google Analytics / Plausible / Umami | Explicitly forbidden by PRD |
| Firebase SDK on site | No auth or database needs; violates zero third-party rule |
| Service worker | PWA features explicitly excluded |
| CMS (Contentful, Sanity, etc.) | Static hand-written HTML is sufficient |

---

### Directory Map

```text
pixel-quest-web/
├── public/                 # Served static files
│   ├── *.html              # HTML5 markup
│   ├── assets/
│   │   ├── css/            # CSS custom properties
│   │   ├── js/             # Vanilla ES modules
│   │   ├── fonts/          # Press Start 2P (.woff2)
│   │   ├── img/            # SVG icons, WebP screenshots, PNG OG previews
│   │   └── downloads/      # .apk binaries
│   └── robots.txt, sitemap.xml
├── docs/                   # Markdown documentation
├── tools/                  # Bash build and deploy scripts
└── firebase.json           # Hosting configuration and CSP headers
```

---

### Deploy Pipeline

```text
Developer Machine  ──git push──>  CI (Validation)  ──firebase deploy──>  Firebase CDN
```

Manual deployment steps:

```bash
firebase deploy --only hosting
```

---

### Version Pinning & Browser Support

- **Runtime:** No client dependencies.
- **CI Tooling:** Exact versions pinned (e.g., `"html-validate": "8.9.0"`).
- **Supported Browsers:** iOS Safari 16+, Android Chrome 110+, Firefox 110+, Desktop Chrome/Safari/Firefox (last 2 versions).

---

### Mobile vs. Web Summary

| Concern | Mobile App | Website |
|---|---|---|
| Language | Dart | HTML / CSS / JS |
| State | Provider | None (Static) |
| Auth | Firebase Auth | None |
| Data | Firestore | None |
| Offline | Local Persistence | Browser Cache |
| Build | `flutter build apk` | None |
| Deploy | Play Store (Planned) | `firebase deploy` |
| Test | 608+ Dart tests | Lighthouse / pa11y |