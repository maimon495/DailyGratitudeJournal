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

## Active Branch
`feature/ads-monetization`

## Current Version
`MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 11`, bundle ID
`com.brianherz.DailyGratitudeJournal`, team `F669HYU266`, **iPhone only**.

The App Store Connect version record is **1.0** — a build only attaches to a
version record whose number matches exactly, so keep these in step. App Store
Connect app name is "Gratitude Journaling Every Day", Apple ID `6758810550`.

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

### API version note
The SDK is pinned to **Google Mobile Ads 11.13.0** (`upToNextMajorVersion` from 11.0.0), which uses
the **`GAD`/`UMP`-prefixed** API (`GADBannerView`, `GADRequest`, `UMPConsentInformation`).
Google's current docs show the unprefixed v12+ names (`BannerView`, `ConsentInformation`) — those
will not compile here. Moving to v12+ is a breaking rename across `BannerAdView` and `ConsentManager`.

### Auth
- Firebase Auth with Sign in with Apple + Google. `AuthService.deleteAccount()` implements
  in-app account deletion (App Store Review Guideline 5.1.1(v)); Settings deletes the Firebase
  user first, then the local SwiftData entries, so a failed delete never destroys journal data.
- The `applesignin` entitlement is applied to **both** Debug and Release configs. It was
  Release-only, which broke Sign in with Apple in Debug builds on device.

## What Still Needs Doing
Done since: signing works (archive + distribution-signed .ipa verified), privacy
policy and support page are live on GitHub Pages and wired into Settings, DSA
trader status is complete, and build 1.0 (10) is on TestFlight.

1. **Verify the banner renders on device** — still the biggest unknown. Ad
   rendering sits behind the auth gate, so it has never been confirmed on real
   hardware. A brand-new AdMob app also gets little or no fill until the app is
   published and linked, so an empty banner may be expected rather than broken.
2. **Verify account deletion on device** — a reviewer will test it.
3. **Reconcile Privacy Nutrition Labels** in App Store Connect with
   `PrivacyInfo.xcprivacy` (crib sheet in `docs/app-store-listing.md`).
4. **Replace the 5 stale 6.5" screenshots** in App Store Connect with the four
   6.9" captures in `docs/screenshots/`.
5. **Account deletion + reauthentication** — Firebase requires a recent sign-in
   to delete. The code surfaces a "sign out and back in" message on
   `requiresRecentLogin` rather than running a full reauth flow.
6. **app-ads.txt** — needs root-level hosting (`maimon495.github.io/app-ads.txt`,
   i.e. a separate user-page repo). Only matters once live.

## Key Design Tokens (JournalTheme.swift)
- `JournalTheme.warmWhite` — navigation bar background
- `JournalTheme.goldAccent` — primary accent color
- `JournalTheme.inkNavy` — primary text
- `JournalTheme.inkCharcoal` — secondary text
- `JournalTheme.cream` — card/input backgrounds
- `JournalTheme.pageMargin` — standard horizontal padding
