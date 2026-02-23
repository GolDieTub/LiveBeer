//
//  AppCoordinatorViewModel.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

@MainActor
final class AppCoordinatorViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home

    @Published var isWelcomePresented: Bool = false
    @Published var isRegistrationPresented: Bool = false
    @Published var isLoginPresented: Bool = false
    @Published var isPhoneEntryPresented: Bool = false

    @Published var pendingPhone: String = ""
    @Published var pendingDebugCode: String = ""

    @Published var isAuthenticated: Bool = SessionManager.shared.isAuthenticated

    private var session = SessionManager.shared
    
    func openPhoneEntry() { isPhoneEntryPresented = true }
    func closePhoneEntry() { isPhoneEntryPresented = false }

    func openWelcome() { isWelcomePresented = true }
    func closeWelcome() { isWelcomePresented = false }

    func openRegistration() { isRegistrationPresented = true }
    func closeRegistration() { isRegistrationPresented = false }

    func openLogin(phone: String, debugCode: String) {
        pendingPhone = phone
        pendingDebugCode = debugCode
        isLoginPresented = true
    }

    func closeLogin() { isLoginPresented = false }

    func signIn(phone: String) {
        session.signIn(phone: phone)
        isAuthenticated = true
    }

    func signOut() {
        session.signOut()
        isAuthenticated = false
    }
}
