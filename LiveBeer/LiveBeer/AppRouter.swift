//
//  AppRouter.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published private(set) var modalStack: [AppRoute] = []
    @Published var overlayError: AppOverlayError? = nil

    var currentModal: AppRoute? { modalStack.last }
    var previousModal: AppRoute? { modalStack.dropLast().last }

    func push(_ route: AppRoute) {
        withAnimation(.default) {
            path.append(route)
        }
    }

    func pop() {
        guard !path.isEmpty else { return }
        withAnimation(.default) {
            path.removeLast()
        }
    }

    func resetPath() {
        withAnimation(.default) {
            path = NavigationPath()
        }
    }

    func presentRoot(_ route: AppRoute) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            modalStack = [route]
        }
    }

    func modalPush(_ route: AppRoute) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            modalStack.append(route)
        }
    }
    
    func modalReplaceTop(with route: AppRoute) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            _ = modalStack.popLast()
            modalStack.append(route)
        }
    }

    func modalPop() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            _ = modalStack.popLast()
        }
    }

    func dismissModal() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            modalStack.removeAll()
        }
    }

    func showError(title: String = "Ошибка", message: String, buttonTitle: String = "OK") {
        overlayError = AppOverlayError(title: title, message: message, buttonTitle: buttonTitle)
    }

    func clearError() {
        overlayError = nil
    }
}
