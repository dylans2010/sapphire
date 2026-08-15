import Foundation
import CoreGraphics

enum InputMonitoringAccess {
    static var isGranted: Bool {
        CGPreflightListenEventAccess()
    }

    @discardableResult
    static func request() -> Bool {
        CGRequestListenEventAccess()
    }
}
