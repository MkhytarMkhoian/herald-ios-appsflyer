import HeraldCore

/// Logs a purchase as `af_purchase`. Throws if a parameter clashes with a key it sets itself.
public struct PurchaseAppsFlyerEventTracker: AppsFlyerEventTracker {
    private let event: AppsFlyerPurchaseEvent
    private let sdk: any AppsFlyerSDK

    public init(event: AppsFlyerPurchaseEvent) {
        self.init(event: event, sdk: LiveAppsFlyerSDK())
    }

    init(event: AppsFlyerPurchaseEvent, sdk: any AppsFlyerSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() throws {
        sdk.logEvent("af_purchase", values: try event.toAppsFlyerEventValues())
    }
}
