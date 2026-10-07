import AppsFlyerLib
import Foundation
import HeraldCore

/// Sends ad revenue through AppsFlyer's `logAdRevenue`.
public struct AdRevenueAppsFlyerEventTracker: AppsFlyerEventTracker {
    private let event: AppsFlyerAdRevenueEvent
    private let sdk: any AppsFlyerSDK

    public init(event: AppsFlyerAdRevenueEvent) {
        self.init(event: event, sdk: LiveAppsFlyerSDK())
    }

    init(event: AppsFlyerAdRevenueEvent, sdk: any AppsFlyerSDK) {
        self.event = event
        self.sdk = sdk
    }

    public func track() {
        let data = AFAdRevenueData(
            monetizationNetwork: event.monetizationNetwork,
            mediationNetwork: event.mediationNetwork,
            currencyIso4217Code: event.currency,
            eventRevenue: NSNumber(value: event.revenue))
        sdk.logAdRevenue(data, additionalParameters: event.parameters.toAppsFlyerEventValues())
    }
}
