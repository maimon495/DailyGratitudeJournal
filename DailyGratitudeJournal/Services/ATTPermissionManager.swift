import Foundation

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

@MainActor
final class ATTPermissionManager {
    static let shared = ATTPermissionManager()
    private init() {}

    func requestTrackingPermission() async {
        #if canImport(AppTrackingTransparency)
        // iOS requires a short delay after the app becomes active before presenting the ATT prompt
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        _ = await ATTrackingManager.requestTrackingAuthorization()
        #endif
    }
}
