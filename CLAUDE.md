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
├── DailyGratitudeJournalApp.swift   # App entry point, Firebase + AdMob init, ATT prompt
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
│       ├── PageFlipView.swift
│       ├── EntryDetailView.swift
│       ├── JournalTheme.swift       # Design tokens (colors, fonts, styles)
│       └── InkColorPicker.swift
└── Services/
    ├── AuthService.swift
    ├── AppleSignInHelper.swift
    ├── NotificationManager.swift    # Daily push notifications
    └── ATTPermissionManager.swift   # App Tracking Transparency prompt
```

## Active Branch
`feature/ads-monetization` — branched from `claude/mobile-phone-access-Z7TqG`

## What's Been Done
### AdMob / Monetization (feature/ads-monetization)
- Added `BannerAdView.swift` — wraps `GADBannerView` via `UIViewRepresentable`. Uses `#if canImport(GoogleMobileAds)` so the app builds before the SDK is installed. Falls back to a visible placeholder.
- Added `ATTPermissionManager.swift` — requests iOS 14.5+ App Tracking Transparency permission with a 1s delay (required by Apple before showing the prompt).
- Updated `DailyGratitudeJournalApp.swift` — calls `MobileAds.shared.start()` on launch and triggers `ATTPermissionManager` when the user hits the main screen.
- Updated `TodayView.swift` — banner ad pinned to the bottom of the screen, below the scroll area.
- Updated `WeeklyJournalView.swift` — banner ad placed below the search bar.
- Updated `Info.plist` — added `GADApplicationIdentifier` (test ID) and `NSUserTrackingUsageDescription`.
- Updated `project.pbxproj` — registered AdMob SPM package (`https://github.com/googleads/swift-package-manager-google-mobile-ads`, v11+), linked `GoogleMobileAds` in Frameworks build phase, and registered the two new Swift files in the Xcode project.

## What Still Needs Doing (Monetization)
1. **Create an AdMob account** at admob.google.com
2. **Replace placeholder IDs** once the AdMob account is set up:
   - `Info.plist` → `GADApplicationIdentifier`: replace `ca-app-pub-3940256099942544~1458002511`
   - `BannerAdView.swift` → `adUnitID`: replace `ca-app-pub-3940256099942544/2934735716`
   - (Both are currently Google's official test IDs — safe for development)
3. **Verify SDK resolves** — open project in Xcode, SPM should auto-fetch Google Mobile Ads

## App Store Readiness Checklist
- [ ] Apple Developer account ($99/year) — developer.apple.com
- [ ] Set real Bundle ID (currently `com.brianherz.DailyGratitudeJournal`)
- [ ] App icon 1024×1024px PNG (no alpha)
- [ ] Screenshots for iPhone 6.7" and 6.5"
- [ ] Privacy policy URL (required — AdMob and Firebase Auth both collect data)
- [ ] App Store Connect listing (name, description, keywords, category)
- [ ] Privacy Nutrition Labels filled out in App Store Connect
- [ ] Replace AdMob test IDs with real ones
- [ ] Archive and upload via Xcode → Product → Archive

## Key Design Tokens (JournalTheme.swift)
- `JournalTheme.warmWhite` — navigation bar background
- `JournalTheme.goldAccent` — primary accent color
- `JournalTheme.inkNavy` — primary text
- `JournalTheme.inkCharcoal` — secondary text
- `JournalTheme.cream` — card/input backgrounds
- `JournalTheme.pageMargin` — standard horizontal padding
