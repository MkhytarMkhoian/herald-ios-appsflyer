/// One call to AppsFlyer for one event. A factory builds it.
public protocol AppsFlyerEventTracker {
    func track() throws
}
