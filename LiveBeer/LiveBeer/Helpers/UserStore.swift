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

    let usersKey = "lb.users.v1"
    @Published private(set) var users: [User] = []

    private init() {
        users = load()
    }

    func exists(phone: String) -> Bool {
        users.contains(where: { $0.phone == phone })
    }

    func user(phone: String) -> User? {
        users.first(where: { $0.phone == phone })
    }

    func add(_ user: User) {
        guard !exists(phone: user.phone) else { return }
        users.append(user)
        save(users)
    }

    func upsert(_ user: User) {
        if let idx = users.firstIndex(where: { $0.phone == user.phone }) {
            users[idx] = user
        } else {
            users.append(user)
        }
        save(users)
    }

    func delete(phone: String) {
        users.removeAll(where: { $0.phone == phone })
        save(users)
    }

    private func load() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey) else { return [] }
        return (try? JSONDecoder().decode([User].self, from: data)) ?? []
    }

    private func save(_ users: [User]) {
        guard let data = try? JSONEncoder().encode(users) else { return }
        UserDefaults.standard.set(data, forKey: usersKey)
    }
}
