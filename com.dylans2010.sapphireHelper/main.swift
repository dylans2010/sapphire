import Foundation
import OSLog

private let mainLogger = Logger(subsystem: "com.dylans2010.sapphireHelper", category: "Main")

let pid = ProcessInfo.processInfo.processIdentifier
let processName = ProcessInfo.processInfo.processName
let execPath = Bundle.main.executablePath ?? "unknown"
let bundleID = Bundle.main.bundleIdentifier ?? "com.dylans2010.sapphireHelper"

mainLogger.info("[HelperStartup] Starting privileged helper process. PID: \(pid), ProcessName: \(processName), Path: \(execPath), BundleID: \(bundleID), MachService: \(Constant.helperMachLabel)")
NSLog("[HelperStartup] Starting privileged helper process. PID: %d, Path: %@, BundleID: %@, MachService: %@", pid, execPath, bundleID, Constant.helperMachLabel)

XPCServer.shared.start()

mainLogger.info("[HelperStartup] XPCServer listener initialized, entering CFRunLoopRun()")
NSLog("[HelperStartup] XPCServer listener initialized, entering CFRunLoopRun()")

CFRunLoopRun()

mainLogger.error("[HelperLifecycle] RunLoop exited unexpectedly!")
NSLog("[HelperLifecycle] RunLoop exited unexpectedly!")
