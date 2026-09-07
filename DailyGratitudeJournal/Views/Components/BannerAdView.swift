import SwiftUI

/// Production AdMob banner ad unit for this app.
private let adUnitID = "ca-app-pub-8780809101780422/8208596455"

/// Height reserved for the ad slot. Anchored adaptive banners are 50pt tall
/// on iPhone in portrait, and the slot is a fixed size on purpose: the space
/// is reserved whether or not an ad has loaded, so content never shifts.
private let bannerSlotHeight: CGFloat = 50

/// Anchored banner shown at the bottom of a screen.
///
/// The banner is sized strictly from the space it is given and then clipped.
/// This matters more than it looks: a `GADBannerView` reports the loaded ad's
/// own size, and if that is allowed to propagate it makes every ancestor as
/// wide as the ad — which pushed the whole Today screen off both edges and
/// hid the ink and font pickers.
///
/// Renders nothing until `ConsentManager` reports that ads may be requested,
/// so no ad request is ever made before UMP consent has been resolved.
struct BannerAdView: View {
    @ObservedObject private var consentManager = ConsentManager.shared

    var body: some View {
        GeometryReader { proxy in
            Group {
                if consentManager.canRequestAds {
                    AdaptiveBannerAd(width: proxy.size.width)
                }
            }
            .frame(width: proxy.size.width, height: bannerSlotHeight, alignment: .center)
        }
        .frame(height: bannerSlotHeight)
        .clipped()
    }
}

#if canImport(GoogleMobileAds)
import GoogleMobileAds
import UIKit

private struct AdaptiveBannerAd: UIViewRepresentable {
    /// Width of the slot the ad must fit inside.
    let width: CGFloat

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
        // Never let the ad's own size dictate the layout around it.
        banner.translatesAutoresizingMaskIntoConstraints = true
        banner.clipsToBounds = true
        return banner
    }

    func updateUIView(_ bannerView: GADBannerView, context: Context) {
        guard width > 0, context.coordinator.loadedWidth != width else { return }
        context.coordinator.loadedWidth = width

        if bannerView.rootViewController == nil {
            bannerView.rootViewController = Self.rootViewController()
        }
        // An anchored adaptive banner fills the width it is given, which fills
        // better than a fixed 320x50 on larger iPhones.
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        bannerView.load(GADRequest())
    }

    /// Keeps the hosted view from reporting an intrinsic size to SwiftUI.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: GADBannerView, context: Context) -> CGSize? {
        CGSize(width: width, height: bannerSlotHeight)
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
    let width: CGFloat

    var body: some View {
        Text("Ad placeholder — add Google Mobile Ads SDK via SPM")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(width: width, height: bannerSlotHeight)
            .background(Color(.systemGray6))
    }
}

#endif
