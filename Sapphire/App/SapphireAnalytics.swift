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

        if !isConfigured && FirebaseApp.app() == nil {
            let settings = SettingsModel.shared.settings
            let googleAppID = settings.googleAppID.trimmingCharacters(in: .whitespacesAndNewlines)

            if !googleAppID.isEmpty {
                let senderID = settings.googleGCMSenderID.trimmingCharacters(in: .whitespacesAndNewlines)
                let options = FirebaseOptions(googleAppID: googleAppID, gcmSenderID: senderID.isEmpty ? "0" : senderID)

                let apiKey = settings.googleAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
                if !apiKey.isEmpty {
                    options.apiKey = apiKey
                }

                let projectID = settings.googleProjectID.trimmingCharacters(in: .whitespacesAndNewlines)
                if !projectID.isEmpty {
                    options.projectID = projectID
                }

                FirebaseApp.configure(options: options)
                isConfigured = true
            } else if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
                FirebaseApp.configure()
                isConfigured = true
            }
        } else if FirebaseApp.app() != nil {
            isConfigured = true
        }

        applyCollectionPreference()
    }

    static func applyCollectionPreference() {
        guard isConfigured || FirebaseApp.app() != nil else { return }
        Analytics.setAnalyticsCollectionEnabled(isEnabled)
    }

    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        guard isEnabled else { return }

        if !isConfigured && FirebaseApp.app() == nil {
            bootstrap()
        }

        guard isConfigured || FirebaseApp.app() != nil else { return }
        Analytics.logEvent(name, parameters: parameters)
    }
}
