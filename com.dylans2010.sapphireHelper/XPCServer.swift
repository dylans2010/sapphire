import Foundation
import OSLog

private let serverLogger = Logger(subsystem: "com.dylans2010.sapphireHelper", category: "XPCServer")

class XPCServer: NSObject {

    internal static let shared = XPCServer()
    private var listener: NSXPCListener?

    internal func start() {
        let serviceName = Constant.helperMachLabel
        serverLogger.info("[XPCServer] Starting NSXPCListener for Mach service: \(serviceName)")
        NSLog("[XPCServer] Starting NSXPCListener for Mach service: %@", serviceName)

        let newListener = NSXPCListener(machServiceName: serviceName)
        newListener.delegate = self
        self.listener = newListener
        newListener.resume()

        serverLogger.info("[XPCServer] NSXPCListener resumed and listening for incoming XPC connections")
        NSLog("[XPCServer] NSXPCListener resumed and listening for incoming XPC connections")
    }

    private func connectionInterruptionHandler(for pid: pid_t) {
        serverLogger.warning("[XPCServer] Connection interrupted for PID \(pid)")
        NSLog("[XPCServer] Connection interrupted for PID %d", pid)
    }

    private func connectionInvalidationHandler(for pid: pid_t) {
        serverLogger.warning("[XPCServer] Connection invalidated for PID \(pid)")
        NSLog("[XPCServer] Connection invalidated for PID %d", pid)
    }

    private func isValidClient(forConnection connection: NSXPCConnection) -> Bool {
        let clientPID = connection.processIdentifier
        serverLogger.info("[XPCServer] Validating client PID: \(clientPID)")
        NSLog("[XPCServer] Validating client PID: %d", clientPID)

        do {
            let matches = try CodesignCheck.codeSigningMatches(pid: clientPID)
            serverLogger.info("[XPCServer] Code signing check for PID \(clientPID) result: \(matches)")
            NSLog("[XPCServer] Code signing check for PID %d result: %@", clientPID, matches ? "MATCH" : "NO_MATCH")
            return matches
        } catch {
            let nsErr = error as NSError
            serverLogger.error("[XPCServer] Code signing check failed for PID \(clientPID) with error: \(error.localizedDescription) (Domain: \(nsErr.domain), Code: \(nsErr.code))")
            NSLog("[XPCServer] Code signing check failed for PID %d with error: %@ (Domain: %@, Code: %ld)", clientPID, error.localizedDescription, nsErr.domain, nsErr.code)
            return false
        }
    }
}

extension XPCServer: NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let clientPID = newConnection.processIdentifier
        serverLogger.info("[XPCServer] New incoming connection request from PID \(clientPID)")
        NSLog("[XPCServer] New incoming connection request from PID %d", clientPID)

        if !isValidClient(forConnection: newConnection) {
            serverLogger.error("[XPCServer] Client PID \(clientPID) failed code signature validation. Rejecting connection.")
            NSLog("[XPCServer] Client PID %d failed code signature validation. Rejecting connection.", clientPID)
            return false
        }

        serverLogger.info("[XPCServer] Client PID \(clientPID) passed validation. Exporting HelperProtocol interface...")
        NSLog("[XPCServer] Client PID %d passed validation. Exporting HelperProtocol interface...", clientPID)

        let helper = Helper()

        let interface = NSXPCInterface(with: HelperProtocol.self)
        interface.setClasses(
            NSSet(array: [FanInfo.self, NSNull.self]) as! Set<AnyHashable>,
            for: #selector(HelperProtocol.getFanInfo(fanIndex:reply:)),
            argumentIndex: 0,
            ofReply: true
        )
        newConnection.exportedInterface = interface
        newConnection.exportedObject = helper

        newConnection.remoteObjectInterface = NSXPCInterface(with: InstallationClient.self)

        newConnection.interruptionHandler = { [weak self] in
            self?.connectionInterruptionHandler(for: clientPID)
        }
        newConnection.invalidationHandler = { [weak self] in
            self?.connectionInvalidationHandler(for: clientPID)
        }

        newConnection.resume()

        helper.client = newConnection.remoteObjectProxy as? InstallationClient

        serverLogger.info("[XPCServer] Successfully accepted and resumed connection for PID \(clientPID)")
        NSLog("[XPCServer] Successfully accepted and resumed connection for PID %d", clientPID)

        return true
    }
}
