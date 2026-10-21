
---

## File 3 of 9 — `DATA_MODEL.md`

# Data Model — Pixel Quest

This document describes the data model of the **mobile app**. The website
is a **read-only marketing surface** that does not touch any of this data.
The website reproduces a subset of it as static content (tier list, XP
curve table, streak examples) so visitors can understand the game without
running the app.

---

## 1. Firestore schema

Root path: `/databases/{database}/documents`.

```text
users/{uid} ← one doc per registered user
├─ level: int
├─ currentXp: int
├─ xpToNext: int
├─ totalXp: int ← lifetime earned minus XP spent
├─ streak: int
├─ xpSpent: int
├─ streakFreezes: int
├─ lastActive: string ← "YYYY-MM-DD" ISO date, empty if never
├─ streakHistory: string[] ← ISO dates, unique
├─ updatedAt: timestamp ← server-assigned
│
└─ quests/{questId} ← one doc per quest
├─ title: string
├─ category: string ← "health" | "fitness" | "selfImprovement" | "skills"
├─ xp: int ← 5–100
├─ completedDates: string[] ← ISO dates, at most one per day
├─ reminderTime: string|null ← "HH:mm" 24-hour, null = no reminder
└─ updatedAt: timestamp

usernames/{key} ← public registry, unique per user
├─ uid: string ← Firebase Auth UID
└─ createdAt: timestamp
```

`key = username.trim().toLowerCase()`. The lowercase key ensures usernames are case-insensitively unique. `usernames` is readable by anyone (even unauthenticated), writable only by the owning uid.

---

## 2. Local cache schema (SharedPreferences)

The app is offline-first. Every value in Firestore is mirrored locally, plus session state that never leaves the device.

### Global (per device)

| Key | Type | Default | Purpose |
|---|---|---|---|
| `pq_has_account` | bool | `false` | Has this device ever registered a user? (ratchet — never resets) |
| `pq_is_logged_in` | bool | `false` | Is there an active session? |
| `pq_remember_me` | bool | `true` | Persist session across launches? |
| `pq_user_id` | string? | `null` | Current Firebase Auth UID |
| `pq_email` | string? | `null` | Current user's email |
| `pq_username` | string? | `null` | Current user's display name |

### Per user (all keyed by `_<uid>`)

| Key | Type | Default |
|---|---|---|
| `pq_quests_<uid>` | JSON string | `"[]"` |
| `pq_level_<uid>` | int | `0` |
| `pq_current_xp_<uid>` | int | `0` |
| `pq_xp_to_next_<uid>` | int | `100` |
| `pq_total_xp_<uid>` | int | `0` |
| `pq_streak_<uid>` | int | `0` |
| `pq_xp_spent_<uid>` | int | `0` |
| `pq_streak_freezes_<uid>` | int | `0` |
| `pq_last_active_<uid>` | string? | `null` |
| `pq_streak_history_<uid>` | JSON string | `"[]"` |
| `pq_suggestions_dismissed_<uid>` | JSON string | `"{}"` |

All payloads are JSON-serialized. Corrupt JSON parses to the default — never throws.

---

## 3. Domain models (in-memory)

### Quest

```dart
class Quest {
  final String id;                  // microsecondsSinceEpoch at creation
  String title;
  QuestCategory category;
  int xp;                           // 5..100
  List<String> _completedDates;     // ISO dates, immutable externally
  String? reminderTime;             // "HH:mm" or null

  bool get completed;               // true if todayIso ∈ _completedDates
  void addCompletion(String iso);
  void removeCompletion(String iso);
  Quest copyWith({..., bool clearReminder = false});
}
#### QuestCategory

| name | label | color | icon |
|---|---|---|---|
| health | HEALTH | #3AA0FF | drop |
| fitness | FITNESS | #FF4D8F | humanrun |
| selfImprovement | SELF IMPROVEMENT | #FF4D8F | bookopen |
| skills | SKILLS | #9D6BFF | code |

#### Tier

| Tier | Level range | Flavor |
|---|---|---|
| NOVICE | 0–4 | Every legend starts somewhere. |
| SQUIRE | 5–14 | Your training begins. |
| KNIGHT | 15–29 | Steel yourself for what's ahead. |
| CHAMPION | 30–49 | The crowd roars your name. |
| HERO | 50–74 | Legends are written by heroes. |
| LEGEND | 75–99 | Your name echoes through ages. |
| MYTHIC | 100+ | You have transcended mortality. |
earned(total)  = Σ (quest.xp × quest.completedDates.length)  for every quest
spent(total)   = xpSpent
available      = max(0, earned − spent)

xpToNext(L)    = 100 + 50 × L        (L = 0-based)
cumulative(L)  = 100×L + 25×L×(L−1)  (XP to reach level L from zero)
| Level | XP to reach from zero | XP for this level |
|---:|---:|---:|
| 0 | 0 | 100 |
| 1 | 100 | 150 |
| 2 | 250 | 200 |
| 3 | 450 | 250 |
| 5 | 1,000 | 350 |
| 10 | 3,250 | 600 |
| 25 | 17,500 | 1,350 |
| 50 | 66,250 | 2,600 |
| 100 | 257,500 | 5,100 |
One quest at 10 XP, completed every day for a year → ~3,650 XP → level ≈ 20.
## 5. Streak model
Two independent concepts:

Global streak (users/{uid}.streak, lastActive, streakHistory) — bumped on the first quest completion of a day; broken after a missed day unless a freeze is spent.

Per-quest streak — computed on demand: questStreak(quest) counts consecutive days ending today present in completedDates. Used only for the reminder suggestion (≥ 3 days triggers a nudge).

#### Freeze decision table

Evaluated on every cold start:

| lastActive | freezes owned | Outcome |
|---|---:|---|
| today or yesterday | any | no action |
| two days ago | ≥ 1 | consume — subtract 1, set lastActive = yesterday, add yesterday to history |
| two days ago | 0 | break (streak = 0) |
| three+ days ago | any | break (streak = 0) |
| null | any | nothing to preserve (streak = 0) |
Freeze price: 500 XP. Maximum owned: 2.

## 6. What the website shows
The website reproduces the following static views of this data model so visitors can understand the game at a glance:

| Data model concept | Website presentation |
|---|---|
| Tier list | "Climb the ranks" section on index.html — 7 badges with icon, name, level range |
| XP curve | Compact table on features.html — level 0/1/2/5/10/25/50/100 |
| Category set | Grid of 4 cards on features.html |
| Streak freeze mechanic | 3-step diagram on features.html |
| Sample quest list | Screenshot on index.html |
Everything is hardcoded HTML. Nothing is fetched at runtime.
