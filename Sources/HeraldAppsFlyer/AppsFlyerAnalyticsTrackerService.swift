import HeraldCore

/// Sends events to AppsFlyer, as its factory chain decides. The calls for one event run in order,
/// and if one fails the rest don't run. Anything no factory claims isn't sent.
///
/// AppsFlyer keeps no user attributes, so there are no properties.
///
/// ```swift
/// let tracker = AppsFlyerAnalyticsTrackerService(
///     eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory([
///         PurchaseAppsFlyerEventTrackerFactory()  // your own: purchases as af_purchase
///     ])
/// )
/// ```
public struct AppsFlyerAnalyticsTrackerService: EventTrackerService {
    private let eventTrackerFactory: any AppsFlyerEventTrackerFactory

    public init(eventTrackerFactory: any AppsFlyerEventTrackerFactory) {
        self.eventTrackerFactory = eventTrackerFactory
    }

    public func track(_ event: any Event) {
        do {
            for tracker in try eventTrackerFactory.create(event).handlers() {
                try tracker.track()
            }
        } catch {
            Herald.reportFailure(error)
        }
    }
}
