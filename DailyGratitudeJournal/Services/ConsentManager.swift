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
    private var retryTask: Task<Void, Never>?

    private init() {}

    /// Gathers consent, then starts the ads SDK if it is permitted.
    /// Safe to call more than once; the SDK is only started on the first pass.
    ///
    /// Returns as soon as the first attempt resolves so the caller can move on
    /// to the ATT prompt — Google's consent endpoint can hang for ten seconds,
    /// and the tracking prompt should not sit behind that. If ads still can't
    /// be requested afterwards, retries continue in the background.
    func gatherConsentAndStartAds() async {
        #if canImport(UserMessagingPlatform)
        await runConsentPass()

        if !UMPConsentInformation.sharedInstance.canRequestAds {
            scheduleRetries()
        }
        #else
        // No UMP available (e.g. SDK not resolved) — fall back to starting ads.
        startMobileAds()
        #endif
    }

    #if canImport(UserMessagingPlatform)
    /// One full consent cycle: refresh consent info, then present the form if
    /// one is required. Starts the ads SDK at each point it becomes allowed.
    private func runConsentPass() async {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

        // A failure here is usually a network problem. It is not fatal — any
        // previously stored consent still counts, so canRequestAds is always
        // consulted afterwards regardless of the error.
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
    }

    /// Retries the consent cycle with backoff. Without this a single failed
    /// request — a dropped connection at launch, say — would leave the app
    /// with no ads until it was killed and relaunched.
    private func scheduleRetries() {
        guard retryTask == nil else { return }

        retryTask = Task { [weak self] in
            for delay in [2.0, 8.0, 20.0] {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled, let self else { return }
                guard !UMPConsentInformation.sharedInstance.canRequestAds else { return }
                await self.runConsentPass()
            }
            self?.retryTask = nil
        }
    }

    /// Called when the app returns to the foreground, so a user who was
    /// offline at launch starts seeing ads once they reconnect.
    func retryIfNeeded() {
        guard !didStartMobileAds else { return }
        guard !UMPConsentInformation.sharedInstance.canRequestAds else {
            startMobileAdsIfAllowed()
            return
        }
        scheduleRetries()
    }
    #endif

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
        retryTask?.cancel()
        retryTask = nil

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
