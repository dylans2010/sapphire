import Firebase
import FirebaseAnalytics

enum SapphireAnalytics {
    private static let lock = NSLock()
    private static var isConfigured = false

    static var isEnabled: Bool {
        SettingsModel.shared.settings.googleAnalyticsEnabled
    }

    static func bootstrap() {
        lock.lock()
        defer { lock.unlock() }

        if !isConfigured {
            FirebaseApp.configure()
            isConfigured = true
        }
        applyCollectionPreference()
    }

    static func applyCollectionPreference() {
        guard isConfigured else { return }
        Analytics.setAnalyticsCollectionEnabled(isEnabled)
    }

    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        guard isEnabled else { return }

        if !isConfigured {
            bootstrap()
        }
        Analytics.logEvent(name, parameters: parameters)
    }
}