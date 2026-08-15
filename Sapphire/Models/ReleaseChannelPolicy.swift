import Foundation

enum ReleaseChannelPolicy {
    static var runningBuildChannel: ReleaseChannel {
        BetaEntitlementRuntime.isBetaBuild ? .beta : .stable
    }

    static func preferredChannel(from settings: Settings) -> ReleaseChannel {
        return settings.releaseChannel
    }

    static func displayedChannel(for settings: Settings) -> ReleaseChannel {
        if runningBuildChannel == .beta {
            return .beta
        }
        return preferredChannel(from: settings)
    }

    static func canChangePreferredChannel() -> Bool {
        runningBuildChannel != .beta
    }

    static func reconcileStoredPreference(_ settings: inout Settings) {
        // Beta software updates available for all users
    }
}