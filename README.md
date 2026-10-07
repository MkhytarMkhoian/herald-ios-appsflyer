# Herald for AppsFlyer

Sends [Herald](https://github.com/MkhytarMkhoian/herald-ios) conversions, purchases, subscriptions
and ad revenue to AppsFlyer, over the
[AppsFlyer iOS SDK](https://github.com/AppsFlyerSDK/AppsFlyerFramework).

## Install

In Xcode, File → Add Package Dependencies, and add both packages:

- `https://github.com/MkhytarMkhoian/herald-ios`, for `HeraldCore`;
- `https://github.com/MkhytarMkhoian/herald-ios-appsflyer`, for `HeraldAppsFlyer`.

It works with AppsFlyer 7, and needs iOS 15 or newer.

## Set up

Set up the shared `AppsFlyerLib` as usual, with your dev key, app id and delegate, but don't call
`start()` yourself: Herald starts it when the user agrees. Then:

```swift
import HeraldAppsFlyer
import HeraldCore

let tracker = AppsFlyerAnalyticsTrackerService(
    eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory([
        PurchaseAppsFlyerEventTrackerFactory()  // your own, below
    ])
)
let service = AppsFlyerAnalyticsService()

let provider = HeraldProvider(
    name: "appsflyer",
    events: tracker,
    identity: service,
    lifecycle: service,
    consent: service
)
```

AppsFlyer is for conversions, each one chosen on purpose, so the usual chain has no generic factory:
only the events a factory handles reach AppsFlyer. Add `GenericAppsFlyerEventTrackerFactory()` last
to send everything else under its own name.

| Herald | AppsFlyer |
| --- | --- |
| an event a factory handles | `logEvent(_:withValues:)`, with each value as its own type |
| an `AppsFlyerPurchaseEvent` | `af_purchase` with `af_revenue`, `af_currency` and optional content, quantity and order id |
| an `AppsFlyerSubscribeEvent` | `af_subscribe` with `af_revenue` and `af_currency` |
| an `AppsFlyerAdRevenueEvent` | `logAdRevenue`, with its parameters as additional parameters |
| `identify` / `reset` | `customerUserID = id` / `customerUserID = nil` |
| `start` | stops AppsFlyer, so it stays silent until consent |
| `setEnabled(true)` / `setEnabled(false)` | resumes and starts AppsFlyer / stops it |

A purchase or subscription with a parameter whose key it sets itself, such as `af_revenue`, is
refused and sent to Herald's error reporter, so the value you meant is never quietly replaced.

**Consent.** AppsFlyer forgets both the stop and the user id between launches, so on every launch
call `identify`, then `setEnabled` with the user's stored answer.

## Purchases

Your events don't conform to AppsFlyer's types. A factory of your own builds one from your event:

```swift
import HeraldAppsFlyer
import HeraldCore

struct PurchaseAppsFlyerEventTrackerFactory: AppsFlyerEventTrackerFactory {
    func create(_ event: any Event) -> Resolution<any AppsFlyerEventTracker> {
        guard let purchase = event as? PurchaseCompleted else {
            return .declined
        }
        let appsFlyerPurchase = AppsFlyerPurchaseEvent(
            name: purchase.name, revenue: purchase.price, currency: purchase.currency,
            contentId: purchase.productId, orderId: purchase.orderId)
        return .claimed([PurchaseAppsFlyerEventTracker(event: appsFlyerPurchase)])
    }
}
```

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides.

## License

Apache License 2.0. See [LICENSE](LICENSE).
