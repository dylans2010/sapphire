//
//  IntelligenceModels.swift
//  Sapphire
//

import Foundation
import Combine
import AppKit

public enum LLMBackend: String, Codable, Equatable, CaseIterable, Sendable {
    case auto = "auto"
    case gemini = "gemini"
    case hackclub = "hackclub"
    case openAI = "openai"
    case anthropic = "anthropic"
    case openRouter = "openrouter"
    case xAI = "xai"
    case nvidia = "nvidia"

    public var isKeyConfigured: Bool {
        let keyMgr = APIKeyManager.shared
        switch self {
        case .auto:
            return keyMgr.hasGeminiKey || keyMgr.hasHackClubKey || keyMgr.hasOpenAIKey || keyMgr.hasAnthropicKey || keyMgr.hasOpenRouterKey || keyMgr.hasXAIKey || !keyMgr.nvidiaAPIKey.isEmpty
        case .gemini:
            return keyMgr.hasGeminiKey
        case .hackclub:
            return keyMgr.hasHackClubKey
        case .openAI:
            return keyMgr.hasOpenAIKey
        case .anthropic:
            return keyMgr.hasAnthropicKey
        case .openRouter:
            return keyMgr.hasOpenRouterKey
        case .xAI:
            return keyMgr.hasXAIKey
        case .nvidia:
            return !keyMgr.nvidiaAPIKey.isEmpty
        }
    }

    public func resolveAPIKey(fallbackGeminiKey: String = "") -> String {
        let keyMgr = APIKeyManager.shared
        switch self {
        case .auto:
            if keyMgr.hasGeminiKey { return keyMgr.googleGeminiAPIKey }
            if !fallbackGeminiKey.isEmpty { return fallbackGeminiKey }
            if keyMgr.hasHackClubKey { return keyMgr.hackClubAPIKey }
            if keyMgr.hasOpenAIKey { return keyMgr.openAIAPIKey }
            if keyMgr.hasAnthropicKey { return keyMgr.anthropicAPIKey }
            if keyMgr.hasOpenRouterKey { return keyMgr.openRouterAPIKey }
            if keyMgr.hasXAIKey { return keyMgr.xaiAPIKey }
            if !keyMgr.nvidiaAPIKey.isEmpty { return keyMgr.nvidiaAPIKey }
            return ""
        case .gemini:
            return keyMgr.hasGeminiKey ? keyMgr.googleGeminiAPIKey : fallbackGeminiKey
        case .hackclub:
            return keyMgr.hackClubAPIKey
        case .openAI:
            return keyMgr.openAIAPIKey
        case .anthropic:
            return keyMgr.anthropicAPIKey
        case .openRouter:
            return keyMgr.openRouterAPIKey
        case .xAI:
            return keyMgr.xaiAPIKey
        case .nvidia:
            return keyMgr.nvidiaAPIKey
        }
    }
}

public enum GeminiSpeedMode: String, Codable, Equatable, CaseIterable, Sendable {
    case fast = "fast"
    case precise = "precise"
}

public enum GeminiModelOption: String, Codable, Equatable, CaseIterable, Sendable {
    case flash35Lite = "gemini-1.5-flash"
    case flash = "gemini-2.0-flash"
    case pro = "gemini-1.5-pro"
}

public enum OpenAIModelOption: String, Codable, Equatable, CaseIterable, Sendable {
    case auto = "auto"
    case gpt4o = "gpt-4o"
    case gpt4oMini = "gpt-4o-mini"
    case o3Mini = "o3-mini"
}

public enum AnthropicModelOption: String, Codable, Equatable, CaseIterable, Sendable {
    case auto = "auto"
    case claude35Sonnet = "claude-3-5-sonnet-latest"
    case claude35Haiku = "claude-3-5-haiku-latest"
}

public enum OpenRouterModelPreset: String, Codable, Equatable, CaseIterable, Sendable {
    case auto = "auto"
}

public enum XAIModelOption: String, Codable, Equatable, CaseIterable, Sendable {
    case auto = "auto"
    case grok2 = "grok-2-latest"
}

public enum NVIDIAModelOption: String, Codable, Equatable, CaseIterable, Sendable {
    case auto = "auto"
    case llama33 = "meta/llama-3.3-70b-instruct"
}

public enum BlipModelPreferences {
    private static let openAIKey = "blip_openai_model"
    private static let anthropicKey = "blip_anthropic_model"
    private static let openRouterKey = "blip_openrouter_model"
    private static let xaiKey = "blip_xai_model"
    private static let nvidiaKey = "blip_nvidia_model"

    public static var openAIModel: String {
        get { UserDefaults.standard.string(forKey: openAIKey) ?? "auto" }
        set { UserDefaults.standard.set(newValue, forKey: openAIKey) }
    }

    public static var anthropicModel: String {
        get { UserDefaults.standard.string(forKey: anthropicKey) ?? "auto" }
        set { UserDefaults.standard.set(newValue, forKey: anthropicKey) }
    }

    public static var openRouterModelStored: String {
        get { UserDefaults.standard.string(forKey: openRouterKey) ?? "auto" }
        set { UserDefaults.standard.set(newValue, forKey: openRouterKey) }
    }

    public static var xaiModel: String {
        get { UserDefaults.standard.string(forKey: xaiKey) ?? "auto" }
        set { UserDefaults.standard.set(newValue, forKey: xaiKey) }
    }

    public static var nvidiaModel: String {
        get { UserDefaults.standard.string(forKey: nvidiaKey) ?? "auto" }
        set { UserDefaults.standard.set(newValue, forKey: nvidiaKey) }
    }
}

public struct IntelligenceResult: Sendable {
    public var success: Bool
    public var subtasksCompleted: Int
    public var subtasksTotal: Int
    public var actionsTaken: Int
    public var duration: Double

    public init(
        success: Bool = true,
        subtasksCompleted: Int = 0,
        subtasksTotal: Int = 0,
        actionsTaken: Int = 0,
        duration: Double = 0.0
    ) {
        self.success = success
        self.subtasksCompleted = subtasksCompleted
        self.subtasksTotal = subtasksTotal
        self.actionsTaken = actionsTaken
        self.duration = duration
    }
}

public struct IntelligenceLogEntry: Identifiable, Sendable {
    public var id: UUID
    public var text: String
    public var isError: Bool
    public var isSubtask: Bool

    public init(
        id: UUID = UUID(),
        text: String,
        isError: Bool = false,
        isSubtask: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isError = isError
        self.isSubtask = isSubtask
    }
}

@MainActor
public final class IntelligenceNotchViewModel: ObservableObject {
    @Published public var taskInput: String = ""
    @Published public var isRunning: Bool = false
    @Published public var subtaskProgress: (current: Int, total: Int) = (0, 0)
    @Published public var lastResult: IntelligenceResult? = nil
    @Published public var logEntries: [IntelligenceLogEntry] = []

    public init() {}

    public func run(apiKey: String, backend: LLMBackend, geminiSpeedMode: GeminiSpeedMode) {
        isRunning = true
    }

    public func stop() {
        isRunning = false
    }
}

public final class ScreenPerception: @unchecked Sendable {
    public init() {}

    public func captureAnnotatedScreen() async -> (NSImage?, [Any]) {
        return (nil, [])
    }
}
