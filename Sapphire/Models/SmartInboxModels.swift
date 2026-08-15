//
//  SmartInboxModels.swift
//  Sapphire
//

import Foundation
import Combine

public struct OTPEvent: Identifiable, Equatable, Sendable {
    public var id: String
    public var code: String
    public var source: String
    public var title: String
    public var body: String
    public var date: Date

    public init(
        id: String = UUID().uuidString,
        code: String,
        source: String = "",
        title: String = "",
        body: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.code = code
        self.source = source
        self.title = title
        self.body = body
        self.date = date
    }
}

public enum ParcelCarrier: String, Sendable, CaseIterable {
    case usps, fedex, ups, dhl, amazon, unknown

    public var displayName: String {
        switch self {
        case .usps: return "USPS"
        case .fedex: return "FedEx"
        case .ups: return "UPS"
        case .dhl: return "DHL"
        case .amazon: return "Amazon"
        case .unknown: return "Package"
        }
    }
}

public struct ParcelShipment: Identifiable, Sendable {
    public var id: String
    public var carrier: ParcelCarrier
    public var title: String
    public var status: String
    public var isDelivered: Bool
    public var trackingNumber: String
    public var trackingURL: URL?
    public var detail: String

    public init(
        id: String = UUID().uuidString,
        carrier: ParcelCarrier = .unknown,
        title: String = "",
        status: String = "",
        isDelivered: Bool = false,
        trackingNumber: String = "",
        trackingURL: URL? = nil,
        detail: String = ""
    ) {
        self.id = id
        self.carrier = carrier
        self.title = title
        self.status = status
        self.isDelivered = isDelivered
        self.trackingNumber = trackingNumber
        self.trackingURL = trackingURL
        self.detail = detail
    }
}

@MainActor
public final class SmartInboxMonitor: ObservableObject {
    public static let shared = SmartInboxMonitor()

    @Published public var latestOTP: OTPEvent?
    @Published public var activeParcels: [ParcelShipment] = []

    private var consumedOTPCodes: Set<String> = []

    private init() {}

    public func hasConsumedOTP(_ code: String) -> Bool {
        consumedOTPCodes.contains(code)
    }

    public func consumeOTP(_ code: String) {
        consumedOTPCodes.insert(code)
    }

    public func dismissOTP() {
        latestOTP = nil
    }
}
