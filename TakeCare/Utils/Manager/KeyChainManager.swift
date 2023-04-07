//
//  KeyChainManager.swift
//  TakeCare
//
//  Created by DONGJU LIM on 2021/11/12.
//

import Foundation
import KeychainSwift

class KeyChainManager: NSObject {
    enum KeyChainKeys: String {
        case uuid              = "UUID_KEY"
        case firebaseAuthToken = "FIREBASE_AUTH_TOKEN"
    }

    let keychain = KeychainSwift()

    static let shared: KeyChainManager = {
        var instance = KeyChainManager()
        instance.keychain.accessGroup = globalKeychainSharingKey
        instance.keychain.synchronizable = true
        return instance
    }()

    func string(forKey: KeyChainKeys) -> String? {
        return keychain.get(forKey.rawValue)
    }

    func data(forKey: KeyChainKeys) -> Data? {
        return keychain.getData(forKey.rawValue)
    }

    func bool(forKey: KeyChainKeys) -> Bool? {
        return keychain.getBool(forKey.rawValue)
    }

    func set(_ value: String, forKey: KeyChainKeys) {
        keychain.set(value, forKey: forKey.rawValue)
    }

    func set(_ value: Data, forKey: KeyChainKeys) {
        keychain.set(value, forKey: forKey.rawValue)
    }

    func set(_ value: Bool, forKey: KeyChainKeys) {
        keychain.set(value, forKey: forKey.rawValue)
    }
}
