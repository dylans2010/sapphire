//
//  EncryptionManager.swift
//  Sapphire
//

import Foundation

public final class EncryptionManager {
    public static let shared = EncryptionManager()

    private init() {}

    public func encrypt(_ data: Data) throws -> Data {
        guard let encrypted = CryptoManager.shared.encrypt(data: data) else {
            throw EncryptionError.encryptionFailed
        }
        return encrypted
    }

    public func decrypt(_ data: Data) throws -> Data {
        guard let decrypted = CryptoManager.shared.decrypt(data: data) else {
            throw EncryptionError.decryptionFailed
        }
        return decrypted
    }

    public enum EncryptionError: Error {
        case encryptionFailed
        case decryptionFailed
    }
}
