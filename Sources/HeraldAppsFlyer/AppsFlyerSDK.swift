import AppsFlyerLib

/// The AppsFlyer calls this module makes, so the tests can record them instead:
/// ``LiveAppsFlyerSDK`` in the app, a recorder in the tests.
protocol AppsFlyerSDK: Sendable {
    func logEvent(_ name: String, values: [String: Any])
    func logAdRevenue(_ data: AFAdRevenueData, additionalParameters: [String: Any])
    func setStopped(_ stopped: Bool)
    func start()
    func setCustomerUserID(_ userID: String?)
}

/// Calls the app's shared `AppsFlyerLib`.
struct LiveAppsFlyerSDK: AppsFlyerSDK {
    func logEvent(_ name: String, values: [String: Any]) {
        AppsFlyerLib.shared().logEvent(name, withValues: values)
    }

    func logAdRevenue(_ data: AFAdRevenueData, additionalParameters: [String: Any]) {
        AppsFlyerLib.shared().logAdRevenue(data, additionalParameters: additionalParameters)
    }

    func setStopped(_ stopped: Bool) {
        AppsFlyerLib.shared().isStopped = stopped
    }

    func start() {
        AppsFlyerLib.shared().start()
    }

    func setCustomerUserID(_ userID: String?) {
        AppsFlyerLib.shared().customerUserID = userID
    }
}
