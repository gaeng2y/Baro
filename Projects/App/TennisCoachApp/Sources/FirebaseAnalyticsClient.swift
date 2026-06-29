import FirebaseAnalytics
import TennisCore

extension AnalyticsClient {
    static let firebase = AnalyticsClient { event in
        Analytics.logEvent(event.name, parameters: event.firebaseParameters)
    }
}

private extension AnalyticsEvent {
    var firebaseParameters: [String: Any]? {
        guard !parameters.isEmpty else {
            return nil
        }
        return parameters.mapValues(\.firebaseValue)
    }
}

private extension AnalyticsValue {
    var firebaseValue: Any {
        switch self {
        case let .string(value):
            value
        case let .int(value):
            value
        case let .double(value):
            value
        case let .bool(value):
            value
        }
    }
}
