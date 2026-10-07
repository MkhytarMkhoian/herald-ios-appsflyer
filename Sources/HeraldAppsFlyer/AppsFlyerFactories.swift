import HeraldCore

/// Logs any event under its own name with its parameters. Claims every event, so it goes last in a
/// chain.
///
/// Most apps leave it out: AppsFlyer is for conversions, each one chosen on purpose, so a chain
/// without a fallback, where only the events a factory handles are sent, is the usual setup.
public struct GenericAppsFlyerEventTrackerFactory: AppsFlyerEventTrackerFactory, FallbackFactory {
    private let sdk: any AppsFlyerSDK

    public init() {
        self.init(sdk: LiveAppsFlyerSDK())
    }

    init(sdk: any AppsFlyerSDK) {
        self.sdk = sdk
    }

    public func create(_ event: any Event) -> Resolution<any AppsFlyerEventTracker> {
        .claimed([GenericAppsFlyerEventTracker(event: event, sdk: sdk)])
    }
}

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
public struct RequireMappedAppsFlyerEventTrackerFactory: AppsFlyerEventTrackerFactory,
    FallbackFactory
{
    public init() {}

    public func create(_ event: any Event) throws -> Resolution<any AppsFlyerEventTracker> {
        throw UnhandledEventError(event: event)
    }
}
