import AppsFlyerLib
import Foundation
import HeraldCore

@testable import HeraldAppsFlyer

struct TestEvent: Event {
    let name: String
    var parameters: [String: AnalyticsValue] = [:]
}

/// Records the AppsFlyer calls instead of making them, each as one line that shows every value's
/// type, like `logEvent af_purchase af_revenue=Double(4.99)`. Locked, so any thread can call it:
/// hence `@unchecked Sendable`.
final class RecordingAppsFlyerSDK: AppsFlyerSDK, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [String] = []

    var calls: [String] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }

    func logEvent(_ name: String, values: [String: Any]) {
        record("logEvent \(name)\(formattedValues(values))")
    }

    func logAdRevenue(_ data: AFAdRevenueData, additionalParameters: [String: Any]) {
        var line = "logAdRevenue \(data.monetizationNetwork)"
        line += " mediation=\(data.mediationNetwork.rawValue)"
        line += " \(data.eventRevenue) \(data.currencyIso4217Code)"
        record(line + formattedValues(additionalParameters))
    }

    func setStopped(_ stopped: Bool) { record("stopped \(stopped)") }

    func start() { record("start") }

    func setCustomerUserID(_ userID: String?) { record("customerUserID \(userID ?? "nil")") }

    private func formattedValues(_ values: [String: Any]) -> String {
        var text = ""
        for key in values.keys.sorted() {
            let value = values[key]!
            text += " \(key)=\(type(of: value))(\(value))"
        }
        return text
    }

    private func record(_ line: String) {
        lock.lock()
        defer { lock.unlock() }
        recorded.append(line)
    }
}

/// What Herald sent to its error reporter. Locked like ``RecordingAppsFlyerSDK``.
final class ReportedFailures: @unchecked Sendable {
    private let lock = NSLock()
    private var failures: [AnalyticsFailure] = []

    var all: [AnalyticsFailure] {
        lock.lock()
        defer { lock.unlock() }
        return failures
    }

    func append(_ failure: AnalyticsFailure) {
        lock.lock()
        defer { lock.unlock() }
        failures.append(failure)
    }
}
