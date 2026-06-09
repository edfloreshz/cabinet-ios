import Foundation
import CryptoKit

enum CryptoServiceError: Error {
    case keyUnavailable
    case invalidCiphertext
}

struct CryptoService {
    private static let keyTag = "dev.edfloreshz.Cabinet.encryptionKey"

    static func loadOrCreateKey() throws -> SymmetricKey {
        if let data = KeychainService.load(key: keyTag) {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        try KeychainService.save(key: keyTag, data: data)
        return key
    }

    static func encryptString(_ string: String) throws -> Data {
        let key = try loadOrCreateKey()
        let plaintext = Data(string.utf8)
        let sealed = try AES.GCM.seal(plaintext, using: key)
        guard let combined = sealed.combined else { throw CryptoServiceError.invalidCiphertext }
        return combined
    }

    static func decryptToString(_ data: Data) throws -> String {
        let key = try loadOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let plaintext = try AES.GCM.open(sealedBox, using: key)
        guard let string = String(data: plaintext, encoding: .utf8) else { throw CryptoServiceError.invalidCiphertext }
        return string
    }
}
