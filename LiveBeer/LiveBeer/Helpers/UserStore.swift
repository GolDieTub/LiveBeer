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

    private let usersKey = "lb.users.v1"
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
        if exists(phone: user.phone) { return }
        users.append(user)
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
