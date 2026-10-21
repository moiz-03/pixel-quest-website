# Security — Pixel Quest

This document covers two systems: the **mobile app** (already built) and the **website** (to be built). The two share nothing at runtime — the website is fully static, and never talks to the app's backend.

---

## Part 1 — Mobile App Security Posture

### 1.1 Authentication

- **Provider:** Firebase Auth (email + password).
- Passwords are never stored by the app; Firebase handles hashing server-side.
- Session tokens live in the OS keychain via `firebase_auth`'s platform integration.
- **Deletion requires reauthentication** (`AuthService.deleteAccount` calls `reauthenticateWithCredential` before touching Firestore). Prevents a stranger who picks up an unlocked phone from wiping an account.

---

### 1.2 Authorization — Firestore Rules

```firestore
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
  match /quests/{questId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
  match /{subcollection=**}/{docId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
}

match /usernames/{username} {
  allow read: if true;                        // public (needed for uniqueness check)
  allow create: if request.auth != null
                && request.resource.data.uid == request.auth.uid;
  allow delete: if request.auth != null
                && resource.data.uid == request.auth.uid;
  allow update: if false;                     // immutable once created
}

match /{document=**} {
  allow read, write: if false;                // deny by default
}
```

**Properties:**
- Owner-only for all user data.
- Usernames are public-read (necessary — the "is this available" check runs unauthenticated), writable only by the claiming `uid`, immutable once created.
- Catch-all deny ensures any new collection is closed by default.
- *Known gap:* Rules do not validate field types or ranges (`totalXp` can be set to 999999 by a malicious client). Accepted trade-off for a solo habit app with no leaderboard. If leaderboards or paid currency are added, add Cloud Function validation.

---

### 1.3 App Check

`main.dart` activates App Check in release builds:
- **Android:** `AndroidProvider.playIntegrity`
- **Apple:** `AppleProvider.deviceCheck`

*Note:* Current implementation treats App Check failure as fatal. Recommended fix: log-and-continue (defence-in-depth, not primary auth).

---

### 1.4 Username Race Condition

`FirestoreService.claimUsername` wraps the write in a Firestore transaction:

```dart
await _db.runTransaction((tx) async {
  final snap = await tx.get(ref);
  if (snap.exists) throw UsernameTakenException(username);
  tx.set(ref, {'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
});
```

Two users racing for the same username: exactly one transaction wins, the other throws `UsernameTakenException`. The losing register rolls back the just-created auth user.

*Known residual gap:* If `claimUsername` throws a network error (not `UsernameTakenException`) and the subsequent `user.delete()` also fails, an orphaned auth user remains — email permanently burned. Production-grade fix requires a Cloud Function that periodically reaps auth users with no usernames doc. Not implemented.

---

### 1.5 Data Deletion

`AuthService.deleteAccount` sequence:
1. Reauthenticate with password.
2. `FirestoreService.deleteAllUserData` (chunked, handles $> 500$ quests) — if this fails, abort.
3. `user.delete()` (auth).
4. Clear `SharedPreferences`.

**Partial-failure invariants:**
- Firestore delete fails $\rightarrow$ auth user preserved $\rightarrow$ user can retry.
- Auth delete fails $\rightarrow$ Prefs preserved $\rightarrow$ user isn't silently signed out.

---

### 1.6 Local Storage

`SharedPreferences` (unencrypted). Holds quest titles, XP, streak history. No passwords, no tokens. Logging out clears session keys. Deleting the account clears all keys for that `uid`.

---

### 1.7 Secrets

- `firebase_options.dart` contains public API keys by design (they are not secrets — Firebase security relies on rules and App Check, not key secrecy).
- No private keys, no service-account JSON, no `.env` file is included in the app.
- **CI:** Only uses `FIREBASE_TOKEN` (never committed).

---

## Part 2 — Website Security Posture

The website is fully static and has no user accounts. This eliminates entire classes of threat.

### 2.1 Attack Surface

| Attack Vector | Present? | Mitigation |
|---|---|---|
| User authentication bypass | No auth | — |
| SQL injection | No DB | — |
| XSS via user input | No user input | — |
| CSRF | No sessions | — |
| Server-side code execution | No server | — |
| Supply-chain via npm/pip | Minimal | Zero runtime deps, no build step |
| Third-party script compromise | None | No third-party scripts |
| Malicious APK replacement | Real risk | SHA-256 published, HTTPS, static-host immutability |
| Clickjacking | Possible | `X-Frame-Options: DENY` in host config |
| DDoS on host | Host-dependent | CDN (Cloudflare / Firebase Hosting) |
| Data exfiltration | None possible | Zero analytics, zero cookies |

---

### 2.2 Content Security Policy

Set at hosting layer (`firebase.json` $\rightarrow$ headers, `_headers` on Netlify, or Cloudflare Transform Rule):

```http
Content-Security-Policy:
  default-src 'self';
  script-src 'self';
  style-src 'self';
  img-src 'self' data:;
  font-src 'self';
  connect-src 'self';
  form-action 'none';
  frame-ancestors 'none';
  base-uri 'self';
  object-src 'none';
  upgrade-insecure-requests;
```

---

### 2.3 Other Security Headers

```http
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=(), interest-cohort=()
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Resource-Policy: same-origin
```

---

### 2.4 APK Integrity

The APK is the only binary the site ships. Every release:
1. Sign the APK with the release keystore (never the debug keystore).
2. Compute `sha256sum pixel-quest-v1.0.0.apk`.
3. Publish the hash on `download.html`.
4. Add the release notes to `changelog.html`.
5. Set `Content-Disposition: attachment` on the APK response so browsers download rather than render.
6. Set `Content-Type: application/vnd.android.package-archive` — some hosts default to `octet-stream`, which triggers extra warnings on Android.

---

### 2.5 Dependency Policy

- Zero client-side libraries. No React, no Vue, no Alpine. Vanilla JS only.
- Zero third-party fonts. Press Start 2P is self-hosted.
- Zero analytics.
- `devDependencies` (only for CI tooling) must pin exact versions and pass `npm audit` on every build.

---

### 2.6 Privacy

**What the site does NOT do:**
- No cookies (any kind).
- No `localStorage` for tracking (only UI prefs like "nav closed").
- No fingerprinting.
- No IP logging beyond the CDN's default access logs (retained $\le 30$ days).
- No third-party origins contacted at runtime.

**What the site DOES do:**
- Serves static content.
- Logs aggregate pageviews via CDN access logs (no per-visitor analysis).

---

### 2.7 Content Constraints

The site must **NOT** contain:
- Any actual user's data (screenshots must use dummy accounts).
- Any secret, token, API key beyond the public Firebase config already shipped in the app.
- Any statement claiming the app is on Google Play / App Store if it isn't.
- Any download link to an APK not signed with the release key.

---

### 2.8 Incident Response

If the APK is ever found to be tampered with:
1. Yank the file from the host immediately.
2. Publish a `SECURITY.md` advisory on the site.
3. Rotate the release signing key if compromise is suspected (forces all users to reinstall from a fresh source — nuclear option).
4. Notify users who've signed up for updates (none currently; consider if scale warrants it).

---

## Part 3 — Known Limitations (Whole Project)

| Limitation | Impact | Mitigation Status |
|---|---|---|
| No server-side validation of XP/levels | Malicious client can inflate totals | Accepted — solo app, no leaderboard |
| Orphaned auth users if rollback fails | Email permanently burned | Not mitigated (would need Cloud Function) |
| App Check failure is fatal on startup | Some devices can't run app | Fix recommended |
| Firestore rules don't cap array size | Slow reads on massive accounts | Accepted for now |
| No rate limiting on registration | Bulk account creation possible | Not mitigated (relies on Firebase Auth limits) |
| `com.example.pixelQuest` bundle ID | Conflicts with any other example app | Must fix before release |