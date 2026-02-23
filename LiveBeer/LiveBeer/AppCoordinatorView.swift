//
//  AppCoordinatorView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

struct AppCoordinatorView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var session = SessionManager.shared
    @StateObject private var registrationVM = RegistrationViewModel()

    var body: some View {
        ZStack {
            TabView {
                NavigationStack(path: $router.path) {
                    if session.isAuthenticated {
                        HomeView(onLogout: { session.signOut() })
                    } else {
                        UnauthorizedView(onLoginTap: { router.presentRoot(.welcome) })
                    }
                }
                .tabItem { Image(systemName: "house"); Text("Главная") }
                .tag(AppTab.home)

                NavigationStack { InfoStubView() }
                    .tabItem { Image(systemName: "info.circle"); Text("Инфо") }
                    .tag(AppTab.info)

                NavigationStack { ShopsStubView() }
                    .tabItem { Image(systemName: "cart"); Text("Магазины") }
                    .tag(AppTab.shops)

                NavigationStack { ProfileStubView() }
                    .tabItem { Image(systemName: "person"); Text("Профиль") }
                    .tag(AppTab.profile)
            }

            if !router.modalStack.isEmpty {
                ZStack {
                    ForEach(Array(router.modalStack.enumerated()), id: \.element.id) { index, route in
                        modalView(for: route)
                            .allowsHitTesting(index == router.modalStack.count - 1)
                            .zIndex(Double(index))
                            .transition(transition(for: route, index: index))
                    }
                }
                .zIndex(1000)
                .animation(.spring(response: 0.35, dampingFraction: 0.9), value: router.modalStack)
            }

            if let err = router.overlayError {
                FullScreenErrorOverlay(error: err) {
                    router.clearError()
                }
                .zIndex(9999)
            }
        }
        .environmentObject(router)
    }

    @ViewBuilder
    private func modalView(for route: AppRoute) -> some View {
        switch route {
        case .welcome:
            WelcomeView(
                viewModel: WelcomeViewModel(
                    onClose: { router.dismissModal() },
                    onLogin: { router.modalPush(.authFlow) },
                    onRegister: { router.modalPush(.registration) },
                    onGuest: { router.dismissModal() }
                )
            )
            .background(Color.white.ignoresSafeArea())

        case .registration:
            RegistrationView(
                vm: registrationVM,
                onBack: { router.modalPop() },
                onSubmit: { Task { await handleRegistrationSubmit() } }
            )
            .background(Color.white.ignoresSafeArea())

        case .authFlow:
            AuthFlowView(
                onBackToWelcome: { router.modalPop() },
                onDone: { phone in
                    session.signIn(phone: phone)
                    router.dismissModal()
                }
            )
            .background(Color.white.ignoresSafeArea())
        }
    }

    private func transition(for route: AppRoute, index: Int) -> AnyTransition {
        guard index > 0 else {
            return .asymmetric(insertion: .opacity, removal: .opacity)
        }

        let from = router.modalStack[index - 1]
        let to = route

        if from == .welcome && to == .authFlow {
            return .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading))
        }

        if from == .welcome && to == .registration {
            return .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing))
        }

        return .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    }

    private func handleRegistrationSubmit() async {
        let ok = registrationVM.validate()

        if let alert = registrationVM.under18Alert {
            router.showError(title: alert.title, message: alert.message, buttonTitle: alert.buttonTitle)
            return
        }

        guard ok else {
            return
        }

        let phone = AuthService.shared.normalizePhone(registrationVM.phone)

        if UserStore.shared.exists(phone: phone) {
            router.showError(
                title: "Регистрация невозможна",
                message: "Пользователь с таким номером уже зарегистрирован. Попробуйте войти или укажите другой номер.",
                buttonTitle: "Понятно"
            )
            registrationVM.showInvalid()
            return
        }

        let user = User(
            phone: phone,
            name: registrationVM.name.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: registrationVM.birthDate.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date()
        )

        UserStore.shared.add(user)

        router.modalPop()
    }
}
