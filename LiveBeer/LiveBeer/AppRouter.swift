//
//  AppRouter.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

struct AppConfirmation: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let isDestructive: Bool
    let onConfirm: () -> Void
}

enum AppSheet: Identifiable, Equatable {
    case infoDetail(article: InfoArticle)

    var id: String {
        switch self {
        case .infoDetail(let article):
            return "infoDetail:\(article.id)"
        }
    }
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published private(set) var modalStack: [AppRoute] = []
    @Published var overlayError: AppOverlayError? = nil
    @Published var confirmation: AppConfirmation? = nil
    @Published var selectedTab: AppTab = .home
    @Published var sheet: AppSheet? = nil
    @Published var overlay: AppOverlay? = nil

    var currentModal: AppRoute? { modalStack.last }
    var previousModal: AppRoute? { modalStack.dropLast().last }

    func selectTab(_ tab: AppTab) {
        withAnimation(.default) {
            selectedTab = tab
        }
    }

    func presentSheet(_ sheet: AppSheet) {
        withAnimation(.easeInOut(duration: 0.18)) {
            self.sheet = sheet
        }
    }

    func dismissSheet() {
        withAnimation(.easeInOut(duration: 0.18)) {
            sheet = nil
        }
    }

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

    func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String,
        cancelTitle: String = "Отмена",
        isDestructive: Bool = true,
        onConfirm: @escaping () -> Void
    ) {
        confirmation = AppConfirmation(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            isDestructive: isDestructive,
            onConfirm: onConfirm
        )
    }

    func clearConfirmation() {
        confirmation = nil
    }

    func presentOverlay(_ overlay: AppOverlay) {
        withAnimation(.easeInOut(duration: 0.18)) {
            self.overlay = overlay
        }
    }

    func dismissOverlay() {
        withAnimation(.easeInOut(duration: 0.18)) {
            overlay = nil
        }
    }
}
