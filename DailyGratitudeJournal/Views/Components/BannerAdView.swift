import SwiftUI

/// Production AdMob banner ad unit for this app.
private let adUnitID = "ca-app-pub-8780809101780422/8208596455"

/// Anchored banner shown at the bottom of a screen.
///
/// Renders nothing until `ConsentManager` reports that ads may be requested,
/// so no ad request is ever made before UMP consent has been resolved.
struct BannerAdView: View {
    @ObservedObject private var consentManager = ConsentManager.shared

    var body: some View {
        if consentManager.canRequestAds {
            AdaptiveBannerAd()
                .frame(height: 50)
        }
    }
}

#if canImport(GoogleMobileAds)
import GoogleMobileAds
import UIKit

private struct AdaptiveBannerAd: UIViewRepresentable {
    final class Coordinator: NSObject, GADBannerViewDelegate {
        /// Width the banner was last sized for, so rotation triggers a reload.
        var loadedWidth: CGFloat = 0

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("BannerAdView failed to load: \(error.localizedDescription)")
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView()
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.rootViewController = Self.rootViewController()
        return banner
    }

    func updateUIView(_ bannerView: GADBannerView, context: Context) {
        // Use the full screen width for an anchored adaptive banner, which
        // fills far better than a fixed 320x50 on larger iPhones and iPads.
        let width = bannerView.window?.windowScene?.screen.bounds.width
            ?? UIScreen.main.bounds.width
        guard width > 0, context.coordinator.loadedWidth != width else { return }

        context.coordinator.loadedWidth = width
        if bannerView.rootViewController == nil {
            bannerView.rootViewController = Self.rootViewController()
        }
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        bannerView.load(GADRequest())
    }

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
    }
}

#else

/// Placeholder shown when the GoogleMobileAds SDK is not available.
private struct AdaptiveBannerAd: View {
    var body: some View {
        Text("Ad placeholder — add Google Mobile Ads SDK via SPM")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
    }
}

#endif
