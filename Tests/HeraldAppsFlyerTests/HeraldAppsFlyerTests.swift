import AppsFlyerLib
import HeraldCore
import Testing

@testable import HeraldAppsFlyer

@Suite struct RevenueTypes {
    @Test func aPurchasePutsItsRevenueUnderAfRevenueAndLeavesAbsentFieldsOut() throws {
        let purchase = AppsFlyerPurchaseEvent(
            name: "purchase", revenue: 4.99, currency: "EUR", contentId: "pro_monthly",
            orderId: "order-1")

        let values = try purchase.toAppsFlyerEventValues()

        #expect(values["af_revenue"] as? Double == 4.99)
        #expect(values["af_currency"] as? String == "EUR")
        #expect(values["af_content_id"] as? String == "pro_monthly")
        #expect(values["af_order_id"] as? String == "order-1")
        #expect(values["af_content_type"] == nil)
        #expect(values["af_quantity"] == nil)
    }

    @Test func aSubscriptionCarriesAfRevenueAndAfCurrency() throws {
        let values = try AppsFlyerSubscribeEvent(name: "sub", revenue: 9.99, currency: "USD")
            .toAppsFlyerEventValues()

        #expect(values.count == 2)
        #expect(values["af_revenue"] as? Double == 9.99)
        #expect(values["af_currency"] as? String == "USD")
    }

    @Test func aParameterWithAKeyTheEventSetsItselfIsRefused() {
        let purchase = AppsFlyerPurchaseEvent(
            name: "purchase", revenue: 4.99, currency: "EUR",
            parameters: ["af_revenue": .double(1)])

        #expect {
            try purchase.toAppsFlyerEventValues()
        } throws: { error in
            "\(error)".contains("can't have a 'af_revenue' parameter")
        }
    }

    @Test func aKeyThePurchaseLeavesEmptyIsFreeForAParameter() throws {
        let purchase = AppsFlyerPurchaseEvent(
            name: "purchase", revenue: 4.99, currency: "EUR",
            parameters: ["af_content_id": .string("from-parameters")])

        #expect(
            try purchase.toAppsFlyerEventValues()["af_content_id"] as? String == "from-parameters")
    }

    @Test func revenueEventsAreEqualByValue() {
        #expect(
            AppsFlyerPurchaseEvent(name: "p", revenue: 1, currency: "EUR")
                == AppsFlyerPurchaseEvent(name: "p", revenue: 1, currency: "EUR"))
        #expect(
            AppsFlyerPurchaseEvent(name: "p", revenue: 1, currency: "EUR")
                != AppsFlyerPurchaseEvent(name: "p", revenue: 1, currency: "EUR", quantity: 2))
        #expect(
            AppsFlyerSubscribeEvent(name: "s", revenue: 1, currency: "EUR")
                != AppsFlyerSubscribeEvent(name: "s", revenue: 2, currency: "EUR"))
    }
}

@Suite struct Trackers {
    let appsFlyer = RecordingAppsFlyerSDK()

    @Test func theGenericTrackerLogsTheEventUnderItsOwnNameWithTypedValues() {
        let event = TestEvent(
            name: "level_completed",
            parameters: ["level": .int(3), "score": .double(9.5), "boss": .bool(true)])

        GenericAppsFlyerEventTracker(event: event, sdk: appsFlyer).track()

        #expect(
            appsFlyer.calls == [
                "logEvent level_completed boss=Bool(true) level=Int(3) score=Double(9.5)"
            ])
    }

    @Test func aPurchaseIsLoggedAsAfPurchaseAndASubscriptionAsAfSubscribe() throws {
        try PurchaseAppsFlyerEventTracker(
            event: AppsFlyerPurchaseEvent(name: "p", revenue: 4.99, currency: "EUR"),
            sdk: appsFlyer
        ).track()
        try SubscribeAppsFlyerEventTracker(
            event: AppsFlyerSubscribeEvent(name: "s", revenue: 9.99, currency: "USD"),
            sdk: appsFlyer
        ).track()

        #expect(
            appsFlyer.calls == [
                "logEvent af_purchase af_currency=String(EUR) af_revenue=Double(4.99)",
                "logEvent af_subscribe af_currency=String(USD) af_revenue=Double(9.99)",
            ])
    }

    @Test func aPurchaseWithAClashingParameterSendsNothing() {
        let purchase = AppsFlyerPurchaseEvent(
            name: "p", revenue: 4.99, currency: "EUR", parameters: ["af_currency": .string("X")])

        #expect(throws: (any Error).self) {
            try PurchaseAppsFlyerEventTracker(event: purchase, sdk: appsFlyer).track()
        }
        #expect(appsFlyer.calls.isEmpty)
    }

    @Test func adRevenueGoesThroughLogAdRevenue() {
        let adRevenue = AppsFlyerAdRevenueEvent(
            name: "ad_shown", monetizationNetwork: "facebook", mediationNetwork: .applovinMax,
            revenue: 0.01, currency: "USD", parameters: ["placement": .string("home")])

        AdRevenueAppsFlyerEventTracker(event: adRevenue, sdk: appsFlyer).track()

        #expect(
            appsFlyer.calls == [
                "logAdRevenue facebook mediation=\(MediationNetworkType.applovinMax.rawValue) "
                    + "0.01 USD placement=String(home)"
            ])
    }
}

/// A purchase, as an app describes it.
private struct PurchaseCompleted: Event {
    let price: Double
    var name: String { "purchase_completed" }
}

/// Sends `PurchaseCompleted` as `af_purchase`, and declines everything else.
private struct PurchaseAppsFlyerEventTrackerFactory: AppsFlyerEventTrackerFactory {
    let sdk: any AppsFlyerSDK

    func create(_ event: any Event) -> Resolution<any AppsFlyerEventTracker> {
        guard let purchase = event as? PurchaseCompleted else {
            return .declined
        }
        let appsFlyerPurchase = AppsFlyerPurchaseEvent(
            name: purchase.name, revenue: purchase.price, currency: "EUR")
        return .claimed([PurchaseAppsFlyerEventTracker(event: appsFlyerPurchase, sdk: sdk)])
    }
}

@Suite struct Factories {
    let appsFlyer = RecordingAppsFlyerSDK()

    @Test func aChainWithoutAFallbackSendsOnlyTheConversionsAFactoryHandles() {
        let tracker = AppsFlyerAnalyticsTrackerService(
            eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory([
                PurchaseAppsFlyerEventTrackerFactory(sdk: appsFlyer)
            ]))
        let herald = Herald(providers: [HeraldProvider(name: "appsflyer", events: tracker)])

        herald.track(PurchaseCompleted(price: 4.99))
        herald.track(TestEvent(name: "cart_viewed"))

        #expect(
            appsFlyer.calls == [
                "logEvent af_purchase af_currency=String(EUR) af_revenue=Double(4.99)"
            ])
    }

    @Test func theGenericFactoryClaimsEverything() throws {
        let factory = GenericAppsFlyerEventTrackerFactory(sdk: appsFlyer)

        #expect(
            try factory.create(TestEvent(name: "anything")).handlers().first
                is GenericAppsFlyerEventTracker)
    }

    @Test func aClashingParameterIsReportedThroughHerald() throws {
        let failures = ReportedFailures()
        let tracker = AppsFlyerAnalyticsTrackerService(
            eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory([
                PurchaseAppsFlyerEventTrackerFactory(sdk: appsFlyer),
                RequireMappedAppsFlyerEventTrackerFactory(),
            ]))
        let herald = Herald(
            providers: [HeraldProvider(name: "appsflyer", events: tracker)],
            errorReporter: { failure in failures.append(failure) }
        )

        herald.track(TestEvent(name: "cart_viewed"))

        let failure = try #require(failures.all.first)
        #expect(failure.provider == "appsflyer")
        #expect(failure.error is UnhandledEventError)
        #expect(appsFlyer.calls.isEmpty)
    }
}

@Suite struct Service {
    let appsFlyer = RecordingAppsFlyerSDK()

    @Test func startKeepsTheSDKStopped() {
        AppsFlyerAnalyticsService(sdk: appsFlyer).start()

        #expect(appsFlyer.calls == ["stopped true"])
    }

    @Test func grantingConsentResumesThenStartsInThatOrder() {
        AppsFlyerAnalyticsService(sdk: appsFlyer).setEnabled(true)

        #expect(appsFlyer.calls == ["stopped false", "start"])
    }

    @Test func revokingConsentStopsTheSDKAndDoesNotStartIt() {
        AppsFlyerAnalyticsService(sdk: appsFlyer).setEnabled(false)

        #expect(appsFlyer.calls == ["stopped true"])
    }

    @Test func identifySetsTheCustomerUserIdAndResetClearsIt() {
        let service = AppsFlyerAnalyticsService(sdk: appsFlyer)

        service.identify(Identity(userId: "user-1"))
        service.reset()

        #expect(appsFlyer.calls == ["customerUserID user-1", "customerUserID nil"])
    }
}
