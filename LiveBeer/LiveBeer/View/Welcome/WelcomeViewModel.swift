//
//  WelcomeViewModel.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

@MainActor
final class WelcomeViewModel: ObservableObject {
    private let onClose: () -> Void
    private let onLogin: () -> Void
    private let onRegister: () -> Void
    private let onGuest: () -> Void

    init(
        onClose: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onRegister: @escaping () -> Void,
        onGuest: @escaping () -> Void
    ) {
        self.onClose = onClose
        self.onLogin = onLogin
        self.onRegister = onRegister
        self.onGuest = onGuest
    }

    func closeTapped() { onClose() }
    func loginTapped() { onLogin() }
    func registerTapped() { onRegister() }
    func guestTapped() { onGuest() }
}
