//
//  Untitled.swift
//  Lloyds
//
//  Created by Manisha on 23/12/25.
//


import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    private let tokenKey = "com.deltafour.bearerToken"

    func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]

        // Try update first
        let attributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            // Add new
            var addQuery = query
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus == errSecSuccess {
                print("🔐 Token added to Keychain")
            } else {
                print("❌ Keychain add error: \(addStatus)")
            }
        } else if status == errSecSuccess {
            print("🔐 Token updated in Keychain")
        } else {
            print("❌ Keychain update error: \(status)")
        }
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let token = String(data: data, encoding: .utf8) else {
            print("🔍 No token in Keychain (status: \(status))")
            return nil
        }

        return token
    }

    func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        print(status == errSecSuccess ? "🗑 Token removed" : "⚠️ No token to remove (status: \(status))")
    }
}
