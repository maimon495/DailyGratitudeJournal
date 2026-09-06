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
`MARKETING_VERSION = 1.1`, `CURRENT_PROJECT_VERSION = 10`, bundle ID
`com.brianherz.DailyGratitudeJournal`, team `F669HYU266`, iPhone + iPad.

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
1. **Signing certificates** — this Mac has *zero* valid code-signing identities and no
   provisioning profiles, so `xcodebuild archive` fails with
   `No signing certificate "iOS Development" found` for team `F669HYU266`.
   Fix in Xcode → Settings → Accounts → add the Apple ID → Manage Certificates.
2. **Privacy policy URL** — set `SettingsView.privacyPolicyURLString`. It is `""` today, which
   hides the row rather than shipping a dead link. App Store Connect requires a live URL.
3. **Reconcile Privacy Nutrition Labels** in App Store Connect with `PrivacyInfo.xcprivacy`.
4. **iPad screenshots** — `TARGETED_DEVICE_FAMILY = "1,2"` means the App Store requires iPad
   screenshots too. Drop iPad support if you don't want to design/test for it.
5. **Verify the banner renders** while signed in — ad rendering sits behind the auth gate and
   has not been visually confirmed on device.
6. **Account deletion + reauthentication** — Firebase requires a recent sign-in to delete.
   The current code surfaces a "sign out and back in" message on `requiresRecentLogin`
   rather than running a full reauth flow.

## Key Design Tokens (JournalTheme.swift)
- `JournalTheme.warmWhite` — navigation bar background
- `JournalTheme.goldAccent` — primary accent color
- `JournalTheme.inkNavy` — primary text
- `JournalTheme.inkCharcoal` — secondary text
- `JournalTheme.cream` — card/input backgrounds
- `JournalTheme.pageMargin` — standard horizontal padding
