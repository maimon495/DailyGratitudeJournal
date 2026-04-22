import SwiftUI

// Replace with your real Ad Unit ID from AdMob console before release.
// Use the test ID below during development to avoid policy violations.
private let adUnitID = "ca-app-pub-3940256099942544/2934735716" // AdMob test banner ID

#if canImport(GoogleMobileAds)
import GoogleMobileAds
import UIKit

private final class BannerAdCoordinator: NSObject, GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("BannerAdView failed to load: \(error.localizedDescription)")
    }
}

struct BannerAdView: UIViewRepresentable {
    private let coordinator = BannerAdCoordinator()

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        banner.delegate = coordinator
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}

#else

// Placeholder shown when GoogleMobileAds SDK is not yet installed.
struct BannerAdView: View {
    var body: some View {
        Text("Ad placeholder — add Google Mobile Ads SDK via SPM")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.systemGray6))
    }
}

#endif
