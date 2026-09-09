# App Review — Guideline 2.1 Information Needed

Apple rejected 1.0 (16) on 2026-09-09 with **Guideline 2.1 – Information Needed –
New App Submission**. This is the standard request sent to developer accounts with
limited review history: not a guideline violation, an information request.

Two things to do:

1. **Record a screen capture on a physical device** — only you can do this (see the
   shot list at the bottom). Apple explicitly requires a real device.
2. **Reply in Resolution Center** with the text below, and paste the same text into
   **App Review Information → Notes** so future submissions don't repeat this.

---

## Reply text — paste verbatim into Resolution Center

```
Thank you for reviewing. Answers to each item below, in order.

A screen recording captured on a physical iPhone running the latest iOS is
attached. It begins with a cold launch from the home screen and shows the
complete typical flow: account registration and login via Sign in with Apple,
writing and saving an entry with ink and typeface selection, the weekly journal
spread with page navigation and search, the On This Day view, Settings, and
finally in-app account deletion.

Regarding user-generated content: journal entries are stored only on the user's
own device using Apple's SwiftData and are never uploaded, transmitted, shared,
or made visible to any other user. There is no social feed, no comments, no
messaging, no profiles, and no sharing feature of any kind. Because no content
is ever visible to another person, there is nothing to report or block, and no
content reporting or blocking mechanism is applicable. The app contains no paid
content and no in-app purchases.

2. PURPOSE AND TARGET AUDIENCE

Daily Gratitude Journal is a private, single-entry-per-day gratitude journal.

The audience is adults who want a simple, quiet, private journaling habit.

The problem it solves: most journaling and gratitude apps are built around
social feeds, cloud sync, subscriptions, or extensive feature sets. Many people
who want to write one sentence a day find that friction, and the privacy
implications of cloud storage, off-putting.

The value it provides: one page per day and nothing more. Entries never leave
the device, so the user's writing is genuinely private. The On This Day view
resurfaces what they wrote on the same date in previous years, which is the
feature users report as most valuable over time. Ink colour and typeface
selection make the journal feel personal rather than utilitarian.

3. SETUP AND ACCESS INSTRUCTIONS

No setup, configuration, or sample files are required.

Login credentials: no demo account is necessary. The reviewer can sign in
directly on the review device using Sign in with Apple, which requires no
approval step or provisioning on our side. Google Sign-In is also available and
works the same way. If you would nonetheless prefer dedicated test credentials,
please let us know and we will create an account and supply them immediately.

To reach the main features after signing in:

- Today tab: type an entry, choose one of six ink colours and a typeface, and
  tap Save Entry. One entry is kept per calendar day; tapping Edit reopens
  today's entry.
- Journal tab: entries are laid out as a weekly spread on ruled paper. Drag from
  the edge of the page to turn to earlier weeks. The search field at the bottom
  filters across all entries.
- Memories tab: shows entries written on today's calendar date in previous
  years.
- Settings tab: total entries and streak statistics, a per-ink usage breakdown,
  a daily reminder time picker, the signed-in account, Sign Out, Delete Account,
  the app version, and a link to the privacy policy. Users in the EEA, UK and
  Switzerland additionally see Ad Privacy Settings, which reopens Google's
  consent form.

Account deletion is at Settings > Delete Account. It re-authenticates the user
with their original provider, revokes the Sign in with Apple token where
applicable, deletes the account from Firebase Authentication, and deletes all
journal entries stored on the device.

4. EXTERNAL SERVICES USED

- Firebase Authentication (Google) — provides Sign in with Apple and Google
  Sign-In. Receives only the account email address, display name, and a user
  identifier. It never receives journal content.
- Google Mobile Ads SDK / AdMob (Google) — serves a single banner advertisement
  at the bottom of the Today and Journal screens. This is the app's only
  revenue source; the app is free with no in-app purchases.
- Google User Messaging Platform (Google) — presents the advertising consent
  form required for users in the EEA, UK and Switzerland, before any ad is
  requested.
- Firebase Analytics (Google) — aggregate usage counts such as screen opens and
  launches. It never receives journal content.
- Apple SwiftData — on-device storage for journal entries. There is no
  application server, no backend of our own, and no cloud storage of entries.

The app uses no payment processors, no AI or machine learning services, no data
providers, and no third-party content sources.

5. REGIONAL DIFFERENCES

The app's features and content are identical in every region. There are no
region-locked features, no regional content variations, and no geographic
restrictions.

There is one legally required behavioural difference: users in the European
Economic Area, the United Kingdom and Switzerland are shown Google's User
Messaging Platform consent form before any advertisement is requested, and can
reopen their choices at any time from Settings > Ad Privacy Settings. This
affects only advertising personalisation. All journalling features behave
identically everywhere.

6. REGULATED INDUSTRY AND PROTECTED THIRD-PARTY MATERIAL

Not applicable. The app does not operate in a regulated industry and contains no
protected third-party material.

The app is listed under Health & Fitness for discoverability, but it provides no
medical, clinical, or health information, guidance, diagnosis, or treatment, and
it does not collect or process any health data. It does not integrate with
HealthKit. It is a notebook for text the user writes themselves.

All text, graphics, icons and the app name are the developer's own original work.
No licensed, trademarked, or third-party protected material is included.
```

---

## Condensed version — for the App Review Information → Notes field

The Notes field caps at 4,000 characters, so the full reply above doesn't fit.
This version does, and is what I wrote into the field via the API.

```
ACCESSING THE APP
No demo account is needed. Sign in with Apple works directly on the review
device with no approval step on our side; Google Sign-In works the same way. If
you would prefer dedicated test credentials, tell us and we will supply them.
No setup or sample files are required.

ACCOUNT DELETION
Settings > Delete Account. It re-authenticates the user with their original
provider, revokes the Sign in with Apple token where applicable, deletes the
Firebase Authentication account, and deletes all journal entries on the device.

NO USER-GENERATED CONTENT
Journal entries are stored only on the user's device via SwiftData. They are
never uploaded, transmitted, shared, or made visible to any other user. There is
no feed, no comments, no messaging, no profiles, and no sharing. Nothing is ever
visible to another person, so no content reporting or blocking mechanism is
applicable. No paid content and no in-app purchases.

PURPOSE AND AUDIENCE
A private, one-entry-per-day gratitude journal for adults who want a simple,
quiet journaling habit. Most journaling apps are built around social feeds,
cloud sync or subscriptions; this is one page a day, stored only on the device.
The On This Day view resurfaces entries from the same date in previous years.
Six ink colours and multiple typefaces make the journal feel personal.

MAIN FEATURES
Today: write one entry per day, choosing ink colour and typeface.
Journal: weekly spread on ruled paper; drag from the page edge to turn to
earlier weeks; search filters all entries.
Memories: entries from today's date in previous years.
Settings: streak statistics, per-ink usage, daily reminder time, account, Sign
Out, Delete Account, privacy policy. Users in the EEA, UK and Switzerland also
see Ad Privacy Settings, which reopens Google's consent form.

EXTERNAL SERVICES
Firebase Authentication (Sign in with Apple, Google Sign-In) — receives only
email, display name and a user ID; never journal content.
Google Mobile Ads / AdMob — one banner ad; the app's only revenue source.
Google User Messaging Platform — advertising consent for EEA/UK/Switzerland.
Firebase Analytics — aggregate screen and launch counts; never journal content.
Apple SwiftData — on-device storage. There is no server or backend of our own.
No payment processors, no AI services, no data providers, no third-party content.

REGIONAL DIFFERENCES
Features and content are identical in all regions. The only difference is the
legally required Google consent form shown to users in the EEA, UK and
Switzerland before any ad is requested, reopenable at Settings > Ad Privacy
Settings. It affects advertising personalisation only.

REGULATED INDUSTRY / PROTECTED MATERIAL
Not applicable. Listed under Health & Fitness for discoverability, but the app
provides no medical or health information, guidance, diagnosis or treatment,
collects no health data, and does not use HealthKit. All text and graphics are
the developer's own original work; no licensed or trademarked material.
```

---

## Screen recording — shot list

Apple requires this on a **physical device running the latest iOS**, not a
simulator. Record with the built-in iOS screen recorder (Control Centre), then
attach the file to the Resolution Center reply.

Cover every item below; the registration, login and deletion flows are explicitly
required.

| # | Show | Why Apple asked |
|---|------|-----------------|
| 1 | Cold launch from the home screen | "The recording must begin with launching the app" |
| 2 | Login screen → **Continue with Apple** → complete sign-in | Account **registration and login** flow |
| 3 | The tracking permission prompt appearing | Demonstrates ATT is implemented honestly |
| 4 | Today tab: type an entry, change ink colour, change typeface, **Save Entry** | Typical user flow |
| 5 | The saved entry showing its ink and typeface labels | Confirms it persisted |
| 6 | Journal tab: weekly spread, turn back a week, then use search | Core feature |
| 7 | Memories tab | Core feature |
| 8 | Settings: scroll past stats and ink collection, toggle the daily reminder | Core feature |
| 9 | Settings → **Delete Account** → confirm → re-authenticate → returns to login | Account **deletion** — mandatory |

Two notes on the recording:

- **Use a throwaway Apple ID for step 9** if you don't want to delete your own
  entries — deletion is real and wipes local data.
- Consider re-registering afterwards so the recording ends on a working app rather
  than a login screen.

Keep it unhurried; a reviewer needs to see each screen settle. Two to three
minutes is normal.

---

## After replying

Apple usually responds within a day or two on a 2.1 request. Because this is an
information request rather than a defect, **no new build is required** — 1.0 (16)
stays attached and re-enters review once they're satisfied.
