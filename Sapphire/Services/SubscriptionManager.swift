import Foundation
import SwiftUI
import Combine

public enum AppFeature: String, CaseIterable, Codable, Hashable {
    case sportsWidget
    case financeWidget
    case liveSports
    case financeLiveActivity
    case betaSoftwareUpdates
    case geminiLive
    case advancedFileConversion
}

public enum SubscriptionTier: String, CaseIterable, Codable, Hashable {
    case basic
    case plus
    case pro
    case ultra
}

public struct SubscriptionEntitlements: Equatable {
    public var features: Set<AppFeature> = Set(AppFeature.allCases)
    public init() {}
}

public struct SubscriptionAccess {
    public static func hasAccess(to feature: AppFeature) -> Bool {
        return true
    }
}

public enum SubscriptionFeatureCatalog {
    public static func minimumTier(for feature: AppFeature) -> SubscriptionTier {
        return .basic
    }

    public static func features(for tier: SubscriptionTier) -> Set<AppFeature> {
        return Set(AppFeature.allCases)
    }

    public static func tierDisplayName(_ tier: SubscriptionTier) -> String {
        return "Ultra"
    }

    public struct TierHighlight: Identifiable {
        public var id: String { tier.rawValue }
        public let tier: SubscriptionTier
        public let name: String
        public let price: String
        public let features: [String]
    }

    public static func marketingTierHighlights() -> [TierHighlight] {
        return [
            TierHighlight(tier: .ultra, name: "Ultra", price: "Free", features: ["All Features Included"])
        ]
    }

    public static func marketingSubtitle(for tier: SubscriptionTier) -> String {
        return "All features included"
    }
}

public enum SubscriptionRevocationReason: String {
    case sessionExpired
    case cancelled

    public var alertMessage: String {
        switch self {
        case .sessionExpired:
            return "Your Sapphire account session expired. Please sign in again to continue using subscriber features."
        case .cancelled:
            return "Your Sapphire subscription is no longer active. Open account settings to review your subscription."
        }
    }
}

public struct BetaEntitlementValidator {
    public init() {}

    public func validateBetaEntitlement() -> Bool {
        SubscriptionManager.shared.hasBetaSoftwareAccess
    }
}

public enum BetaEntitlementRuntime {
    public static var isBetaBuild: Bool {
        return false
    }

    public static func makeValidator() -> BetaEntitlementValidator {
        BetaEntitlementValidator()
    }
}

extension Notification.Name {
    public static let subscriptionEntitlementsDidChange = Notification.Name("subscriptionEntitlementsDidChange")
    public static let subscriptionPaywallRequested = Notification.Name("subscriptionPaywallRequested")
    public static let subscriptionSessionRevoked = Notification.Name("subscriptionSessionRevoked")
    public static let sapphireOpenAccountPane = Notification.Name("sapphireOpenAccountPane")
}

@MainActor
public class SubscriptionManager: ObservableObject {
    public static let shared = SubscriptionManager()

    @Published public var entitlements: SubscriptionEntitlements = SubscriptionEntitlements()
    @Published public var activeTier: SubscriptionTier = .ultra

    public var isPremium: Bool { true }
    public var isPremiumUser: Bool { true }
    public var isSignedIn: Bool { true }
    public var userDisplayName: String { "Pro User" }
    public var userInitials: String { "PRO" }
    public var tierLabel: String { "Ultra" }
    public var tierGradientColors: [Color] { [.purple, .blue] }
    public var hasBetaSoftwareAccess: Bool { true }

    private init() {}

    public func hasAccess(to feature: AppFeature) -> Bool {
        return true
    }

    public func isFeatureEnabled(_ feature: AppFeature) -> Bool {
        return true
    }

    public func bootstrap() async {}

    public func validateSubscriptionStatus() async {}
}
