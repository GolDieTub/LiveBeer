//
//  UserStore.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation
import Combine

@MainActor
final class UserStore: ObservableObject {
    static let shared = UserStore()

    private let legacyUsersArrayKey = "lb.users.v1"
    private let usersByPhoneKey = "lb.usersByPhone.v1"

    @Published private(set) var users: [User] = []

    private var usersByPhone: [String: User] = [:] {
        didSet {
            users = usersByPhone.values.sorted { $0.createdAt > $1.createdAt }
        }
    }

    private init() {
        if let dict = loadDictionary() {
            usersByPhone = dict
        } else {
            let migrated = migrateFromLegacyArrayIfNeeded()
            usersByPhone = migrated
            saveDictionary(migrated)
        }
    }

    func exists(phone: String) -> Bool {
        usersByPhone[phone] != nil
    }

    func user(phone: String) -> User? {
        usersByPhone[phone]
    }

    func add(_ user: User) {
        guard usersByPhone[user.phone] == nil else { return }
        usersByPhone[user.phone] = user
        saveDictionary(usersByPhone)
    }

    func upsert(_ user: User) {
        usersByPhone[user.phone] = user
        saveDictionary(usersByPhone)
    }

    func delete(phone: String) {
        usersByPhone.removeValue(forKey: phone)
        saveDictionary(usersByPhone)
    }

    func deleteAll() {
        usersByPhone.removeAll()
        saveDictionary(usersByPhone)
    }

    private func loadDictionary() -> [String: User]? {
        guard let data = UserDefaults.standard.data(forKey: usersByPhoneKey) else { return nil }
        return try? JSONDecoder().decode([String: User].self, from: data)
    }

    private func saveDictionary(_ dict: [String: User]) {
        guard let data = try? JSONEncoder().encode(dict) else { return }
        UserDefaults.standard.set(data, forKey: usersByPhoneKey)
    }

    private func migrateFromLegacyArrayIfNeeded() -> [String: User] {
        guard let data = UserDefaults.standard.data(forKey: legacyUsersArrayKey),
              let legacy = try? JSONDecoder().decode([User].self, from: data)
        else {
            return [:]
        }

        var dict: [String: User] = [:]
        for u in legacy {
            dict[u.phone] = u
        }

        UserDefaults.standard.removeObject(forKey: legacyUsersArrayKey)
        return dict
    }
}
