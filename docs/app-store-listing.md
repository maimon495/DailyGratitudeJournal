# App Store Connect — listing copy

Paste-ready values for the App Store Connect form. Character limits noted; all
entries below are within them.

---

## Name (30 char max)

```
Daily Gratitude Journal
```
*23 characters.*

> If that exact name is taken, try `Gratitude Journal — Daily` (25) or
> `Daily Gratitude: Journal` (24). App Store Connect tells you at the point of
> creating the app record.

## Subtitle (30 char max)

```
A quiet page for each day
```
*24 characters.*

Alternatives:
- `One good thing, every day` (25)
- `Write it down. Notice more.` (27)

## Promotional text (170 char max — editable without a new build)

```
No feeds, no streaks to perform for anyone else. Just a page a day, in your own ink, kept private on your device. Look back on this day in past years whenever you like.
```
*165 characters.*

## Keywords (100 char max, comma-separated, no spaces after commas)

```
gratitude,journal,diary,daily,mindfulness,reflection,wellbeing,habit,notebook,thankful,mood,calm
```
*95 characters.*

> Don't repeat words already in your name or subtitle — Apple indexes those
> separately, so repeating them wastes the budget.

## Description (4000 char max)

```
Daily Gratitude Journal is a quiet place to write down one good thing each day.

No feed. No followers. No streak leaderboard. Just a page, a date, and whatever you
want to remember about today.

WRITTEN IN YOUR OWN INK

Choose from six fountain pen inks — Stormy Grey, Rouge Hematite, Emerald of Chivor,
Bleu Pervenche, Vert Atlantide and Poussiere de Lune — and the typeface that suits
your handwriting mood. Your journal should look like yours.

A WEEK AT A TIME

Your entries are laid out as a weekly spread on ruled paper, with a page curl that
turns like a real notebook. Flip back through the weeks and see the shape of your
months.

ON THIS DAY

Come back to the same date in previous years. The entries you forgot you wrote are
usually the ones worth rereading.

A GENTLE NUDGE

Set a daily reminder for a time that fits your evening. One notification, no
badgering.

YOUR WRITING STAYS YOURS

Entries are stored on your device and never uploaded to a server. We can't read them
because we never receive them. Delete the app, or delete your account from Settings,
and they're gone.

WHAT YOU GET

• One entry per day, in your choice of ink and typeface
• Weekly journal spread with a page-turn animation
• On This Day — the same date in earlier years
• Current and longest streaks, if you like that sort of thing
• Search across everything you've written
• Daily reminder notification
• Sign in with Apple or Google
• On-device storage — your entries never leave your phone

Daily Gratitude Journal is free and supported by a small banner advertisement.
```

*Roughly 1,650 characters — comfortably inside the limit, and the first three lines
are what people actually see before tapping "more".*

## Category

- **Primary:** Health & Fitness
- **Secondary:** Lifestyle

> Health & Fitness has stronger intent for "gratitude" and "mindfulness" searches.
> Lifestyle is the safer secondary. Avoid Productivity — the competition there is
> task managers and you'd rank nowhere.

## Age rating

Answer the questionnaire honestly. The one that matters:

- **Does your app contain third-party advertising?** → **Yes**

Everything else is None/No. This should land at **4+**.

## Support URL (required)

Served from the same GitHub Pages site as the privacy policy:

```
https://maimon495.github.io/DailyGratitudeJournal/
```

*(Page written — `docs/index.html`. Serves an FAQ and the support email.)*

## Privacy Policy URL (required)

```
https://maimon495.github.io/DailyGratitudeJournal/privacy-policy.html
```

*(Page written — `docs/privacy-policy.html`. Already wired into `SettingsView.swift`.)*

---

## App Review notes

Paste into **App Review Information → Notes**. This pre-empts the two things most
likely to get a journaling app with ads bounced.

```
Thanks for reviewing.

SIGNING IN
The app requires an account so settings persist across devices. You can sign in
directly with Sign in with Apple on the review device — no demo credentials are
needed and no approval step is involved. If you would prefer a test account instead,
please let us know and we will provide one.

ACCOUNT DELETION
In-app account deletion is available at Settings > Delete Account. It permanently
deletes the account and all journal entries on the device.

ADVERTISING AND TRACKING
The app shows a single AdMob banner. The App Tracking Transparency prompt appears
after sign-in. Google's UMP consent flow runs before the ATT prompt so the two do not
overlap; users in the EEA/UK can reopen their choices at Settings > Ad Privacy
Settings. Declining tracking is fully supported and results in non-personalised ads.

PRIVACY
Journal entries are stored on-device using SwiftData and are never transmitted to any
server. Only account details (email, display name, user ID) reach Firebase
Authentication.

FUNCTIONALITY
Beyond daily entry, the app provides a weekly journal spread with page-turn
navigation, an On This Day view surfacing entries from the same date in prior years,
six selectable ink colours and multiple typefaces, streak tracking, full-text search,
and configurable daily reminder notifications.
```

---

## Screenshots

Four 6.9" captures are ready at **1320 × 2868**, which is the size App Store Connect
requires. Upload in this order:

| # | File | Shows |
|---|------|-------|
| 1 | `01-today.png` | Today's entry, 7-day streak — the hook |
| 2 | `02-journal.png` | Weekly spread on ruled paper |
| 3 | `03-memories.png` | On This Day, entries from 2025 and 2024 |
| 4 | `04-settings.png` | Stats, reminders, the six-ink collection |

Since the app is now iPhone-only, 6.9" is the only size you must supply — App Store
Connect scales it down for smaller devices.

> **Optional polish:** these are clean device captions with no marketing text. Adding
> a short caption above each ("One page a day", "A week at a time", "On this day, last
> year") typically lifts conversion. Not required to submit.

---

## What must be true before you can submit

- [x] Distribution certificate exists — archive and signed .ipa verified
- [x] Support email: gratitude.journal.support@gmail.com
- [ ] Bundle ID `com.brianherz.DailyGratitudeJournal` registered with Sign in with Apple
- [x] GitHub Pages enabled (main → /docs)
- [x] Privacy policy + support page live (both return 200)
- [x] `privacyPolicyURLString` set in `SettingsView.swift`
- [ ] Build uploaded and processed in App Store Connect
- [ ] Privacy Nutrition Labels filled to match `PrivacyInfo.xcprivacy`
- [ ] Screenshots uploaded
- [ ] Age rating questionnaire completed
