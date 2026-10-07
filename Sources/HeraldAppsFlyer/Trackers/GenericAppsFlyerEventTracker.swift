import HeraldCore

public struct GenericAppsFlyerEventTracker: AppsFlyerEventTracker {
    private let event: any Event
    private let sdk: any AppsFlyerSDK

    public init(event: any Event) {
        self.init(event: event, sdk: LiveAppsFlyerSDK())
    }

    init(event: any Event, sdk: any AppsFlyerSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() {
        sdk.logEvent(event.name, values: event.parameters.toAppsFlyerEventValues())
    }
}
