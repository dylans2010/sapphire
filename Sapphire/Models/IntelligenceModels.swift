//
//  IntelligenceModels.swift
//  Sapphire
//

import Foundation
import Combine

public enum LLMBackend: String, Codable, Equatable, CaseIterable, Sendable {
    case auto = "auto"
    case gemini = "gemini"
    case openAI = "openai"
    case anthropic = "anthropic"
    case openRouter = "openrouter"
    case xAI = "xai"
    case nvidia = "nvidia"
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

@MainActor
public final class IntelligenceNotchViewModel: ObservableObject {
    @Published public var taskInput: String = ""

    public init() {}
}
