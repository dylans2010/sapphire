import Foundation
import CryptoKit

class EncryptionManager {
    static let shared = EncryptionManager()
    private let cryptoManager = CryptoManager.shared

    private init() {}

    func encrypt(_ data: Data) throws -> Data {
        guard let encrypted = cryptoManager.encrypt(data: data) else {
            throw NSError(domain: "EncryptionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Encryption failed"])
        }
        return encrypted
    }

    func decrypt(_ data: Data) throws -> Data {
        guard let decrypted = cryptoManager.decrypt(data: data) else {
            throw NSError(domain: "EncryptionManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Decryption failed"])
        }
        return decrypted
    }
}
