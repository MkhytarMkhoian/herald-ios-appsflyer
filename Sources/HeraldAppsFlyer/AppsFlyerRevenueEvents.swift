import AppsFlyerLib
import HeraldCore

/// A purchase, as AppsFlyer's `af_purchase`, with its revenue under `af_revenue`.
///
/// Your events don't conform to it: your AppsFlyer factory builds one from your event and sends it
/// with ``PurchaseAppsFlyerEventTracker``.
public struct AppsFlyerPurchaseEvent: Event, Equatable {
    /// Not sent. Only used in failure reports.
    public let name: String
    public let revenue: Double
    public let currency: String
    public let contentId: String?
    public let contentType: String?
    public let quantity: Int?

    /// Sent as `af_order_id`. Makes a purchase sent twice count once.
    public let orderId: String?

    /// Sent with the values above. Don't use their keys.
    public let parameters: [String: AnalyticsValue]

    public init(
        name: String,
        revenue: Double,
        currency: String,
        contentId: String? = nil,
        contentType: String? = nil,
        quantity: Int? = nil,
        orderId: String? = nil,
        parameters: [String: AnalyticsValue] = [:]
    ) {
        self.name = name
        self.revenue = revenue
        self.currency = currency
        self.contentId = contentId
        self.contentType = contentType
        self.quantity = quantity
        self.orderId = orderId
        self.parameters = parameters
    }

    /// The values AppsFlyer receives. Empty optional fields are left out.
    ///
    /// Throws if `parameters` has a key this purchase sets itself.
    func toAppsFlyerEventValues() throws -> [String: Any] {
        var values: [String: Any] = ["af_revenue": revenue, "af_currency": currency]
        if let contentId {
            values["af_content_id"] = contentId
        }
        if let contentType {
            values["af_content_type"] = contentType
        }
        if let quantity {
            values["af_quantity"] = quantity
        }
        if let orderId {
            values["af_order_id"] = orderId
        }
        return try appsFlyerEventValues(self, adding: values)
    }
}

/// A subscription, as AppsFlyer's `af_subscribe`, with its revenue under `af_revenue`. Sent with
/// ``SubscribeAppsFlyerEventTracker``.
public struct AppsFlyerSubscribeEvent: Event, Equatable {
    /// Not sent. Only used in failure reports.
    public let name: String
    public let revenue: Double
    public let currency: String

    /// Sent with the values above. Don't use their keys.
    public let parameters: [String: AnalyticsValue]

    public init(
        name: String, revenue: Double, currency: String,
        parameters: [String: AnalyticsValue] = [:]
    ) {
        self.name = name
        self.revenue = revenue
        self.currency = currency
        self.parameters = parameters
    }

    /// Throws if `parameters` has a key this subscription sets itself.
    func toAppsFlyerEventValues() throws -> [String: Any] {
        try appsFlyerEventValues(self, adding: ["af_revenue": revenue, "af_currency": currency])
    }
}

/// Ad revenue, sent with ``AdRevenueAppsFlyerEventTracker``.
public struct AppsFlyerAdRevenueEvent: Event, Equatable {
    /// Not sent. Only used in failure reports.
    public let name: String

    /// The network that paid for the impression, such as `facebook`.
    public let monetizationNetwork: String
    public let mediationNetwork: MediationNetworkType
    public let revenue: Double
    public let currency: String

    /// Sent as additional parameters.
    public let parameters: [String: AnalyticsValue]

    public init(
        name: String,
        monetizationNetwork: String,
        mediationNetwork: MediationNetworkType,
        revenue: Double,
        currency: String,
        parameters: [String: AnalyticsValue] = [:]
    ) {
        self.name = name
        self.monetizationNetwork = monetizationNetwork
        self.mediationNetwork = mediationNetwork
        self.revenue = revenue
        self.currency = currency
        self.parameters = parameters
    }
}
