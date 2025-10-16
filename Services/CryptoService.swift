//
//  CryptoService.swift
//  Habood
//
//  Created by Stephan Karatselios on 16/10/2025.
//

import Foundation
import CryptoKit
import FirebaseAuth
import Security

public final class FirebaseCrypto {
    public static let shared = FirebaseCrypto()
    private let keychainService = "Habood.FirebaseCrypto.v1"
    private init() {
    }
    
    public func encrypt<T: Encodable>(_ value: T, aad: String? = nil) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        let key = try loadOrCreateKey()
        let sealed = try AES.GCM.seal(data,
                                      using: key,
                                      nonce: AES.GCM.Nonce(),
                                      authenticating: aad.map { Data($0.utf8) } ?? Data())
        guard let combined = sealed.combined else { throw CryptoError.malformedBox }
        return [
            "alg": "AES-GCM",
            "v": 1,
            "ct": combined.base64EncodedString()
        ]
    }

    public func decrypt<T: Decodable>(_ payload: [String: Any], as type: T.Type, aad: String? = nil) throws -> T {
        guard
            let alg = payload["alg"] as? String, alg == "AES-GCM",
            let _ = payload["v"] as? Int,
            let b64 = payload["ct"] as? String,
            let boxData = Data(base64Encoded: b64)
        else {
            throw CryptoError.invalidPayload
        }
        let key = try loadOrCreateKey()
        let box = try AES.GCM.SealedBox(combined: boxData)
        let opened = try AES.GCM.open(box,
                                      using: key,
                                      authenticating: aad.map { Data($0.utf8) } ?? Data())
        return try JSONDecoder().decode(T.self, from: opened)
    }

    public func encryptFields(_ fields: [String: Any], aad: String? = nil) throws -> [String: Any] {
        let boxed = try JSONSerialization.data(withJSONObject: fields, options: [])
        let key = try loadOrCreateKey()
        let sealed = try AES.GCM.seal(boxed,
                                      using: key,
                                      nonce: AES.GCM.Nonce(),
                                      authenticating: aad.map { Data($0.utf8) } ?? Data())
        guard let combined = sealed.combined else { throw CryptoError.malformedBox }
        return ["alg": "AES-GCM", "v": 1, "ct": combined.base64EncodedString()]
    }

    public func decryptFields(_ payload: [String: Any], aad: String? = nil) throws -> [String: Any] {
        guard let b64 = payload["ct"] as? String, let data = Data(base64Encoded: b64) else { throw CryptoError.invalidPayload }
        let key = try loadOrCreateKey()
        let box = try AES.GCM.SealedBox(combined: data)
        let opened = try AES.GCM.open(box, using: key, authenticating: aad.map { Data($0.utf8) } ?? Data())
        let json = try JSONSerialization.jsonObject(with: opened, options: [])
        guard let dict = json as? [String: Any] else { throw CryptoError.invalidJSON }
        return dict
    }

    public func wrapDocument<T: Encodable>(_ value: T, aad: String? = nil) throws -> [String: Any] {
        ["payload": try encrypt(value, aad: aad)]
    }

    public func unwrapDocument<T: Decodable>(_ dict: [String: Any], as type: T.Type, aad: String? = nil) throws -> T {
        guard let payload = dict["payload"] as? [String: Any] else { throw CryptoError.invalidPayload }
        return try decrypt(payload, as: T.self, aad: aad)
    }

    private func loadOrCreateKey() throws -> SymmetricKey {
        let account = Auth.auth().currentUser?.uid ?? "device"
        if let data = try? readKeychain(service: keychainService, account: account) {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let raw = key.withUnsafeBytes { Data($0) }
        try writeKeychain(service: keychainService, account: account, data: raw)
        return key
    }

    private func writeKeychain(service: String, account: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess else { throw CryptoError.keychainFailure(status) }
    }

    private func readKeychain(service: String, account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { throw CryptoError.keyNotFound }
        return data
    }
    
    public enum CryptoError: LocalizedError {
        case keyNotFound
        case keychainFailure(OSStatus)
        case invalidPayload
        case malformedBox
        case invalidJSON

        public var errorDescription: String? {
            switch self {
            case .keyNotFound: return "Encryption key not found."
            case .keychainFailure(let status): return "Keychain error: \(status)."
            case .invalidPayload: return "Invalid encrypted payload."
            case .malformedBox: return "Malformed sealed box."
            case .invalidJSON: return "Invalid JSON structure."
            }
        }
    }
}
