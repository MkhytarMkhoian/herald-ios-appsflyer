import HeraldCore

/// The value with its type kept. AppsFlyer counts revenue only when `af_revenue` arrives as a
/// number, so a number must stay one.
func appsFlyerValue(_ value: AnalyticsValue) -> Any {
    switch value {
    case .string(let text):
        return text
    case .int(let number):
        return number
    case .double(let number):
        return number
    case .bool(let flag):
        return flag
    }
}

extension [String: AnalyticsValue] {
    /// The parameters as AppsFlyer takes them, each value as its own type. For a tracker of your
    /// own: `AppsFlyerLib.shared().logEvent("af_refund", withValues: ...)`.
    public func toAppsFlyerEventValues() -> [String: Any] {
        var values: [String: Any] = [:]
        for (key, value) in self {
            values[key] = appsFlyerValue(value)
        }
        return values
    }
}

/// The event's parameters together with `values`, refusing a parameter that `values` would
/// replace.
func appsFlyerEventValues(_ event: any Event, adding values: [String: Any]) throws -> [String: Any]
{
    for key in event.parameters.keys.sorted() where values[key] != nil {
        throw AppsFlyerRefusal(
            description: "AppsFlyer event '\(event.name)' can't have a '\(key)' parameter: "
                + "it sets that key itself.")
    }
    var result = event.parameters.toAppsFlyerEventValues()
    for (key, value) in values {
        result[key] = value
    }
    return result
}

/// Why this module refused an event: it says what to change.
struct AppsFlyerRefusal: Error, CustomStringConvertible {
    let description: String
}
