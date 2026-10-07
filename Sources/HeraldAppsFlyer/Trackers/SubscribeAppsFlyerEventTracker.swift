import HeraldCore

/// Logs a subscription as `af_subscribe`. Throws if a parameter clashes with a key it sets itself.
public struct SubscribeAppsFlyerEventTracker: AppsFlyerEventTracker {
    private let event: AppsFlyerSubscribeEvent
    private let sdk: any AppsFlyerSDK

    public init(event: AppsFlyerSubscribeEvent) {
        self.init(event: event, sdk: LiveAppsFlyerSDK())
    }

    init(event: AppsFlyerSubscribeEvent, sdk: any AppsFlyerSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() throws {
        sdk.logEvent("af_subscribe", values: try event.toAppsFlyerEventValues())
    }
}
