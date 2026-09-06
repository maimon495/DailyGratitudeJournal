import Foundation
import UIKit

#if canImport(UserMessagingPlatform)
import UserMessagingPlatform
#endif

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Drives Google's User Messaging Platform (UMP) consent flow and starts the
/// Mobile Ads SDK only once consent allows it.
///
/// Google requires a certified consent management platform for users in the
/// EEA and UK; without one, AdMob stops serving ads to those users. Outside
/// those regions `consentStatus` comes back as `.notRequired` and no form is
/// shown, so this runs on every launch and is a no-op for most users.
@MainActor
final class ConsentManager: ObservableObject {
    static let shared = ConsentManager()

    /// True once the Mobile Ads SDK has been started and banners may load.
    @Published private(set) var canRequestAds = false

    /// True when the user must be able to reopen their consent choices,
    /// which requires a "Privacy Settings" entry point in the UI.
    @Published private(set) var isPrivacyOptionsRequired = false

    private var didStartMobileAds = false

    private init() {}

    /// Gathers consent, then starts the ads SDK if it is permitted.
    /// Safe to call more than once; the SDK is only started on the first pass.
    func gatherConsentAndStartAds() async {
        #if canImport(UserMessagingPlatform)
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

        // Errors here are non-fatal — usually no network. We still consult
        // canRequestAds afterwards, which reflects any previously stored consent.
        if let error = await requestConsentInfoUpdate(with: parameters) {
            print("ConsentManager: consent info update failed — \(error.localizedDescription)")
        }

        refreshPrivacyOptionsRequirement()
        startMobileAdsIfAllowed()

        // Presents the consent form only when one is actually required.
        if let error = await loadAndPresentFormIfRequired() {
            print("ConsentManager: consent form failed — \(error.localizedDescription)")
        }

        refreshPrivacyOptionsRequirement()
        startMobileAdsIfAllowed()
        #else
        // No UMP available (e.g. SDK not resolved) — fall back to starting ads.
        startMobileAds()
        #endif
    }

    /// Reopens the consent form so a user can change their choices.
    /// Only meaningful when `isPrivacyOptionsRequired` is true.
    func presentPrivacyOptionsForm() {
        #if canImport(UserMessagingPlatform)
        guard let viewController = Self.topViewController() else { return }
        UMPConsentForm.presentPrivacyOptionsForm(from: viewController) { [weak self] error in
            if let error {
                print("ConsentManager: privacy options form failed — \(error.localizedDescription)")
            }
            Task { @MainActor in
                self?.refreshPrivacyOptionsRequirement()
                self?.startMobileAdsIfAllowed()
            }
        }
        #endif
    }

    // MARK: - UMP plumbing

    #if canImport(UserMessagingPlatform)
    private func requestConsentInfoUpdate(with parameters: UMPRequestParameters) async -> Error? {
        await withCheckedContinuation { continuation in
            UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { error in
                continuation.resume(returning: error)
            }
        }
    }

    private func loadAndPresentFormIfRequired() async -> Error? {
        guard let viewController = Self.topViewController() else { return nil }
        return await withCheckedContinuation { continuation in
            UMPConsentForm.loadAndPresentIfRequired(from: viewController) { error in
                continuation.resume(returning: error)
            }
        }
    }

    private func refreshPrivacyOptionsRequirement() {
        isPrivacyOptionsRequired =
            UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
    }

    private func startMobileAdsIfAllowed() {
        guard UMPConsentInformation.sharedInstance.canRequestAds else { return }
        startMobileAds()
    }
    #endif

    private func startMobileAds() {
        guard !didStartMobileAds else { return }
        didStartMobileAds = true

        #if canImport(GoogleMobileAds)
        GADMobileAds.sharedInstance().start { [weak self] _ in
            Task { @MainActor in
                self?.canRequestAds = true
            }
        }
        #else
        canRequestAds = true
        #endif
    }

    private static func topViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first

        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
