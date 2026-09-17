# App Review — Guideline 4.3(a) Design: Spam

Apple rejected 1.0 (16) on 2026-09-16 under **Guideline 4.3(a) – Design – Spam**,
after the Guideline 2.1 information request had been satisfied. The message names
no specific app and cites the standard four factors (shared source, repackaged
template, purchased template, multiple accounts).

4.3(a) is usually a judgment about a **saturated concept plus generic metadata**,
not an accusation of code theft. So the response has two halves: rebut the
template theory with verifiable facts, and remove the metadata that reads as
category-filler.

## Changes made 2026-09-17

| | Before | After |
|---|---|---|
| App Store name | Gratitude Journaling Every Day | **Inkwell: Gratitude Journal** |
| Primary category | Health & Fitness | **Lifestyle** |
| Secondary category | Lifestyle | **(none)** |
| Keywords | 12 generic category words | rewritten around what the app does |
| Home screen name | `DailyGratitudeJournal` (unspaced, truncated) | **Inkwell** |
| Build | 16 | **17** |

"Daily Gratitude Journal" was the obvious rename and is **already taken on
another account** — the API rejects it with
`ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE.DIFFERENT_ACCOUNT`. That is very likely
why the generic keyword-phrase name was chosen in the first place.

Also removed from App Review Notes: the sentence saying the app was *"listed
under Health & Fitness for discoverability."* Written to show the app makes no
health claims, it reads in a spam review as an admission of category-gaming.

## Reply text — paste into Resolution Center

```
Thank you for the review. We would like to address the 4.3(a) finding directly
and describe the changes we have made.

ON THE FACTORS LISTED

- Same source code or assets as another app: no. This is original SwiftUI
written by the sole developer on this account. The project has a complete Git
history of 47 commits going back to 23 January 2026, and we are glad to provide
repository access or a commit log on request.

- Repackaged or purchased app template: no template was used. There is no app
generator or third-party template code in the project. The only dependencies are
Firebase Authentication and Analytics, Google Mobile Ads, and Google's User
Messaging Platform, all via Swift Package Manager.

- Several similar apps across multiple accounts: this account has one other app
in progress, an unrelated New York transit app, which shares no code, assets or
concept with this one. We have no other developer accounts.

WHAT MAKES THIS APP DISTINCT

The app is built around a deliberately analog writing experience rather than a
notes list:

- Entries are written in one of six real fountain pen inks - Stormy Grey, Rouge
Hematite, Emerald of Chivor, Bleu Pervenche, Vert Atlantide and Poussiere de
Lune - rendered as ink colour on the page, with a choice of typefaces.

- The journal is presented as a weekly spread on ruled paper, and pages turn
with a genuine page curl, not a swipe or a scroll.

- On This Day resurfaces entries written on the same calendar date in previous
years.

- Entries are stored only on the device using SwiftData. There is no server, no
sync, no feed, no profiles and no sharing. We never receive what a user writes,
and the app works fully offline.

CHANGES MADE IN RESPONSE

- Renamed from "Gratitude Journaling Every Day" to "Inkwell: Gratitude Journal",
so the name identifies the app rather than describing a category.

- Primary category changed from Health & Fitness to Lifestyle, and the secondary
category removed. Lifestyle is the accurate home for it; listing it under Health
& Fitness was our error.

- Keywords rewritten around what the app actually does instead of generic
category terms.

- Build 17 sets a display name of "Inkwell", so the home screen, the App Store
listing and the app itself all agree.

If any part of the app still reads as duplicative, we would be grateful to know
which app or which element specifically, and we will address it. We are happy to
provide source access, build logs, or anything else that would help.

Thank you for your time.
```

## If this is refused

1. Appeal to the App Review Board (Resolution Center > Appeal), same evidence.
2. Failing that, the honest reading is that the concept needs functional
   differentiation, not argument — the analog side is the thread worth pulling,
   since it is what no other gratitude journal is doing.
