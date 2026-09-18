# Daily Gratitude Journal — Project Context

## Tech Stack
- **Language:** Swift 5.0
- **Framework:** SwiftUI + SwiftData
- **Platform:** iOS 17.0+ (native, no Mac Catalyst)
- **Auth:** Firebase Auth (Sign in with Apple + Google)
- **Analytics:** Firebase Analytics
- **Local storage:** SwiftData (on-device only)
- **Dependency manager:** Swift Package Manager (via project.pbxproj)

## App Structure
```
DailyGratitudeJournal/
├── DailyGratitudeJournalApp.swift   # App entry, Firebase init, then consent -> ATT
├── Info.plist                       # GADApplicationIdentifier, ATT string, 50 SKAdNetworkItems
├── PrivacyInfo.xcprivacy            # App privacy manifest (required for upload)
├── Models/
│   ├── GratitudeEntry.swift         # SwiftData model
│   ├── InkColor.swift               # 6 ink color options
│   └── JournalFont.swift            # Font options
├── Views/
│   ├── ContentView.swift            # Tab navigation (Today, History, OnThisDay, Settings)
│   ├── TodayView.swift              # Main journaling screen (has banner ad at bottom)
│   ├── HistoryView.swift            # Delegates to WeeklyJournalView
│   ├── OnThisDayView.swift          # Past entries on same calendar date
│   ├── SettingsView.swift
│   ├── LoginView.swift
│   ├── SplashView.swift
│   └── Components/
│       ├── BannerAdView.swift       # AdMob banner (has #if canImport guard)
│       ├── WeeklyJournalView.swift  # Page-flip weekly journal (has banner ad at bottom)
│       ├── WeeklyJournalPageView.swift
│       ├── PageCurlView.swift       # iBooks-style page curl
│       ├── PageFlipView.swift
│       ├── EntryDetailView.swift
│       ├── JournalTheme.swift       # Design tokens (colors, fonts, styles)
│       └── InkColorPicker.swift
└── Services/
    ├── AuthService.swift
    ├── AppleSignInHelper.swift
    ├── NotificationManager.swift    # Daily push notifications
    ├── ConsentManager.swift         # UMP consent; ONLY place ads SDK is started
    └── ATTPermissionManager.swift   # App Tracking Transparency prompt
```

## Branching
Work on a feature branch and open a PR; don't commit to `main` directly. The
ads/monetization, page-curl and account-deletion work is all merged.

## Current Version
`MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 17`, bundle ID
`com.brianherz.DailyGratitudeJournal`, team `F669HYU266`, **iPhone only**.

The App Store Connect version record is **1.0** — a build only attaches to a
version record whose number matches exactly, so keep these in step. App Store
Connect app name is **"Inkwell: Gratitude Journal"**, Apple ID `6758810550`.
The home screen name comes from `CFBundleDisplayName` = `Inkwell`; without that key
it falls back to the product name `DailyGratitudeJournal`, which is unspaced and
truncates. Store name, home screen name and description must agree — a mismatch is
itself a 4.3 / 2.3 signal.

## What's Been Done
### AdMob / Monetization
- `BannerAdView.swift` — anchored **adaptive** banner via `UIViewRepresentable`, guarded by
  `#if canImport(GoogleMobileAds)`. Renders nothing until `ConsentManager.canRequestAds` is true,
  so no ad request is made before consent is resolved.
- `ConsentManager.swift` — Google User Messaging Platform (UMP) consent flow. Required by Google
  for EEA/UK users; without it AdMob stops serving them ads. **This is the only place the Mobile
  Ads SDK is started** — do not call `GADMobileAds.sharedInstance().start` anywhere else.
- `ATTPermissionManager.swift` — ATT prompt, fired *after* the UMP form so the two never collide.
- `Info.plist` — real `GADApplicationIdentifier`, `NSUserTrackingUsageDescription`, and the
  full set of 50 `SKAdNetworkItems` the SDK requires.
- `PrivacyInfo.xcprivacy` — app privacy manifest. Declares `NSPrivacyTracking`, collected data
  types, and the `UserDefaults` required-reason API (`CA92.1`, used by `NotificationManager`).
  Missing this causes ITMS-91053 rejections on upload.

### PageCurlView — read before touching it
`.pageCurl` renders each page through a **layer transform**, which makes it
hostile to the usual SwiftUI-in-UIKit tricks. Two rules learned the hard way:

1. **Never lay a page out mid-update.** Swapping a `UIHostingController`'s
   `rootView` in place, or calling `setViewControllers` directly inside
   `updateUIViewController`, lays the content out against the container's
   provisional bounds. The page then renders **magnified and clipped** — text
   blown up, date headers off screen — and stays that way. Rebuild on the next
   runloop pass, after checking `view.bounds.width > 0`.
2. **Pages must be opaque.** A transparent page curls into a black or ghosted
   sheet instead of paper.

Pages are snapshots, not live views: `WeeklyJournalPageView` is handed concrete
entries, so it does **not** react to SwiftData changes on its own. `PageCurlView`
takes a `contentVersion` and rebuilds when it changes. Without that the journal
shows an empty week forever, because pages get built before SwiftData finishes
loading.

### Ads depend on a reachable consent endpoint
`ConsentManager` gates the ads SDK on `UMPConsentInformation.canRequestAds`.
If Google's `fundingchoicesmessages.google.com` is unreachable, consent never
resolves and **no ads load at all**. It retries with backoff and again on
foreground. Note this Mac's shell has no direct internet egress (proxy only),
so that endpoint times out in the simulator here — that is the environment,
not the app.

### Privacy manifest — the ITMS-91064 trap
`PrivacyInfo.xcprivacy` must keep `NSPrivacyTracking = true` (the app ships
`NSUserTrackingUsageDescription`, and App Store Connect independently reports
`BINARY_INDICATES_APP_TRACKS_USERS`). Given that, **`NSPrivacyTrackingDomains`
must be present and non-empty** — an empty array *or* an absent key is rejected
at automated validation as:

    ITMS-91064: Invalid tracking information

Apple's message reads "NSPrivacyTracking must be true if NSPrivacyTrackingDomains
isn't empty", which is the inverse of the rule actually enforced. Builds 13 and 14
(empty array) and build 15 (key removed) were all rejected; build 16, with the
domains listed, passed.

The bundled GoogleMobileAds and UserMessagingPlatform frameworks declare **neither**
`NSPrivacyTracking` nor `NSPrivacyTrackingDomains` in their own manifests, so the
app's manifest is the only place these can come from. Don't assume the SDKs supply
them.

### Submitting via the App Store Connect API
Most of a submission can be driven by API with a key at
`~/.appstoreconnect/private_keys/`; `xcrun altool` accepts the same key for
uploading builds. Two things cannot: the **App Privacy questionnaire**
(`appDataUsages` is not an exposed resource — it must be done in the web UI and
explicitly **Published**), and creating the app record itself.

Gotchas met along the way: pricing must be set explicitly even for a free app;
`copyright` is required on the version; the privacy policy URL lives on
`appInfoLocalizations`, not the version localization; each new build needs its own
`usesNonExemptEncryption` answer; and a version marked `INVALID_BINARY` requires a
**new build** — the same binary cannot be resubmitted.

`~/.appstoreconnect/tools/check_status.py` reports current version/submission state.

### Answering a rejection does not requeue it
Replying in Resolution Center is only how you *talk* to App Review. A rejected
item stays `REJECTED` / `UNRESOLVED_ISSUES` until it is explicitly pushed back
into the queue, and Apple sends no reminder — the submission simply sits there
looking like you are waiting on them when they are waiting on you.

Requeuing takes **two** clicks, in this order:

1. Version page (Distribution > iOS App 1.0) > **Update Review**. This moves the
   item from Rejected to Ready for Review.
2. Submission page > **Resubmit to App Review**, which is greyed out until step 1
   is done, and is what actually sends it.

The Guideline 2.1 reply of 2026-09-10 sat unqueued for three business days
because only the reply had been posted. The message thread and its attachments
survive the resubmission, so the reviewer still sees the answers and the screen
recording.

**If the version itself changed** (new build, new metadata), there is an extra
step: the first **Update Review** drops the version from `REJECTED` to
`PREPARE_FOR_SUBMISSION` and the submission page still shows the old rejected
item. Click **Update Review** a second time — that is what puts the item back as
Ready for Review — and only then does **Resubmit to App Review** light up. Watch
`versionState` rather than the page, which lags.

### API version note
The SDK is pinned to **Google Mobile Ads 11.13.0** (`upToNextMajorVersion` from 11.0.0), which uses
the **`GAD`/`UMP`-prefixed** API (`GADBannerView`, `GADRequest`, `UMPConsentInformation`).
Google's current docs show the unprefixed v12+ names (`BannerView`, `ConsentInformation`) — those
will not compile here. Moving to v12+ is a breaking rename across `BannerAdView` and `ConsentManager`.

### Auth
- Firebase Auth with Sign in with Apple + Google. `AuthService.deleteAccount()` implements
  in-app account deletion (App Store Review Guideline 5.1.1(v)); Settings deletes the Firebase
  user first, then the local SwiftData entries, so a failed delete never destroys journal data.
- Deletion re-authenticates through whichever provider the user originally used, because Firebase
  refuses to delete an account whose sign-in is more than a few minutes old. For Apple it also
  revokes the token (`revokeToken(withAuthorizationCode:)`), which Apple requires on deletion.
  `AppleSignInHelper` is held in a property for the life of the request — letting it deallocate
  mid-flight is what produced "Sign in with Apple error 1000".
- The `applesignin` entitlement is applied to **both** Debug and Release configs. It was
  Release-only, which broke Sign in with Apple in Debug builds on device.

## What Still Needs Doing
As of 2026-09-17, 1.0 (17) is in `WAITING_FOR_REVIEW` after a **Guideline 4.3(a)
Design: Spam** rejection of build 16. See `docs/app-review-4.3-response.md` for
the reply and the metadata changes made in response (rename to Inkwell, category
moved to Lifestyle, keywords rewritten, display name added).

Gated on approval:

1. **Link the app in AdMob** — AdMob > Apps > "Link to app store". Until then
   AdMob withholds fill, so an empty banner is expected rather than broken. This
   is the single step that turns ads on.
2. **Confirm the banner renders on device** — never yet visually confirmed on real
   hardware. Only meaningful after step 1.

If 4.3(a) is upheld, the fallback is an App Review Board appeal, and past that,
functional differentiation rather than argument — the analog side (real fountain
pen inks, page curl, ruled weekly spreads) is the thread worth pulling.

## Key Design Tokens (JournalTheme.swift)
- `JournalTheme.warmWhite` — navigation bar background
- `JournalTheme.goldAccent` — primary accent color
- `JournalTheme.inkNavy` — primary text
- `JournalTheme.inkCharcoal` — secondary text
- `JournalTheme.cream` — card/input backgrounds
- `JournalTheme.pageMargin` — standard horizontal padding
