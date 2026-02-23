//
//  SessionManager.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation
import Combine

@MainActor
final class SessionManager: ObservableObject {
    static let shared = SessionManager()

    private let currentKey = "lb.session.currentPhone.v1"

    @Published private(set) var currentUserPhone: String?

    var isAuthenticated: Bool { currentUserPhone != nil }

    private init() {
        currentUserPhone = UserDefaults.standard.string(forKey: currentKey)
    }

    func signIn(phone: String) {
        currentUserPhone = phone
        UserDefaults.standard.set(phone, forKey: currentKey)
    }

    func signOut() {
        currentUserPhone = nil
        UserDefaults.standard.removeObject(forKey: currentKey)
    }
}
