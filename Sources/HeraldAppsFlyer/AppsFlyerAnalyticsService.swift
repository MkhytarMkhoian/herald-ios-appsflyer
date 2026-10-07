import HeraldCore

/// AppsFlyer's lifecycle, identity and consent, over the shared `AppsFlyerLib` the app has set up
/// with its dev key, app id and delegate.
///
/// **AppsFlyer starts on consent, not on `start`.** `start` stops AppsFlyer, so a fresh install
/// sends nothing, not even the install, until `setEnabled(true)` turns it on. AppsFlyer forgets
/// both the stop and the user id between launches, so on every launch call `identify`, then
/// `setEnabled` with the stored answer.
///
/// Granular consent, such as `setConsentData` or `anonymizeUser`, is set on `AppsFlyerLib` itself.
public struct AppsFlyerAnalyticsService: AnalyticsLifecycleService, IdentifiableUserService,
    ConsentService
{
    private let sdk: any AppsFlyerSDK

    public init() {
        self.init(sdk: LiveAppsFlyerSDK())
    }

    init(sdk: any AppsFlyerSDK) {
        self.sdk = sdk
    }

    public func start() {
        sdk.setStopped(true)
    }

    /// AppsFlyer has no flush call.
    public func flush() {}

    public func setEnabled(_ enabled: Bool) {
        sdk.setStopped(!enabled)
        if enabled {
            sdk.start()
        }
    }

    public func identify(_ identity: Identity) {
        sdk.setCustomerUserID(identity.userId)
    }

    public func reset() {
        sdk.setCustomerUserID(nil)
    }
}
