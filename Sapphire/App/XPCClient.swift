import Foundation
import OSLog

private let xpcClientLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.dylans2010.Sapphire", category: "XPCClient")

class XPCClient {

    static let shared = XPCClient()

    private let lock = NSLock()
    private var connection: NSXPCConnection?

    var helper: HelperProtocol? {
        lock.lock()
        let connection = self.connection
        lock.unlock()
        guard let connection else {
            xpcClientLogger.warning("[XPCClient] Attempted to get helper proxy, but connection is nil")
            return nil
        }
        return connection.remoteObjectProxyWithErrorHandler { error in
            let nsErr = error as NSError
            xpcClientLogger.error("[XPCClient] Remote object proxy error: \(error.localizedDescription) (Domain: \(nsErr.domain), Code: \(nsErr.code))")
            NSLog("[XPCClient] Remote object proxy error: %@ (Domain: %@, Code: %ld)", error.localizedDescription, nsErr.domain, nsErr.code)
        } as? HelperProtocol
    }

    private init() {}

    func start(force: Bool = false) {
        lock.lock()
        defer { lock.unlock() }

        if force, let existing = connection {
            xpcClientLogger.info("[XPCClient] Force-reconnecting. Invalidating existing XPC connection...")
            existing.invalidationHandler = nil
            existing.interruptionHandler = nil
            existing.invalidate()
            connection = nil
        }

        guard connection == nil else { return }

        let machName = "com.dylans2010.sapphireHelper"
        xpcClientLogger.info("[XPCClient] Creating NSXPCConnection with machServiceName: \(machName), options: .privileged")
        NSLog("[XPCClient] Creating NSXPCConnection with machServiceName: %@, options: .privileged", machName)

        let newConnection = NSXPCConnection(machServiceName: machName, options: .privileged)
        newConnection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)

        newConnection.invalidationHandler = { [weak self] in
            xpcClientLogger.warning("[XPCClient] Connection invalidated")
            NSLog("[XPCClient] Connection invalidated")
            self?.lock.lock()
            self?.connection = nil
            self?.lock.unlock()
        }

        newConnection.interruptionHandler = { [weak self] in
            xpcClientLogger.warning("[XPCClient] Connection interrupted")
            NSLog("[XPCClient] Connection interrupted")
            self?.lock.lock()
            self?.connection = nil
            self?.lock.unlock()
        }

        connection = newConnection
        newConnection.resume()
        xpcClientLogger.info("[XPCClient] Connection resumed")
    }

    func stop() {
        lock.lock()
        let existing = connection
        existing?.invalidationHandler = nil
        existing?.interruptionHandler = nil
        connection = nil
        lock.unlock()
        existing?.invalidate()
        xpcClientLogger.info("[XPCClient] Connection stopped and invalidated")
    }

    func ping(timeout: TimeInterval = 5) async -> Bool {
        xpcClientLogger.info("[XPCClient] Starting ping (timeout: \(timeout)s)...")
        if await pingOnce(timeout: timeout, forceReconnect: false) {
            xpcClientLogger.info("[XPCClient] Ping succeeded on first attempt")
            return true
        }
        xpcClientLogger.info("[XPCClient] First ping attempt failed or timed out. Retrying with forceReconnect...")
        let result = await pingOnce(timeout: timeout, forceReconnect: true)
        xpcClientLogger.info("[XPCClient] Second ping attempt result: \(result)")
        return result
    }

    private func pingOnce(timeout: TimeInterval, forceReconnect: Bool) async -> Bool {
        await withCheckedContinuation { continuation in
            let lock = NSLock()
            var resumed = false

            func resumeOnce(_ value: Bool) {
                lock.lock()
                defer { lock.unlock() }
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: value)
            }

            start(force: forceReconnect)
            guard let helper else {
                xpcClientLogger.warning("[XPCClient] pingOnce: helper proxy is nil")
                resumeOnce(false)
                return
            }

            helper.getVersion { version in
                xpcClientLogger.info("[XPCClient] pingOnce received version: \(version)")
                resumeOnce(true)
            }

            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                xpcClientLogger.warning("[XPCClient] pingOnce timed out after \(timeout)s")
                resumeOnce(false)
            }
        }
    }
}
