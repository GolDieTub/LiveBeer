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
            TabView(selection: $router.selectedTab) {
                NavigationStack(path: $router.path) {
                    if session.isAuthenticated {
                        HomeView()
                    } else {
                        UnauthorizedView(onLoginTap: { router.presentRoot(.welcome) })
                    }
                }
                .tabItem { Image(systemName: "house"); Text("Главная") }
                .tag(AppTab.home)

                NavigationStack { InfoView() }
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

            if let overlay = router.overlay {
                overlayView(for: overlay)
                    .zIndex(4000)
                    .transition(.opacity)
            }

            if let err = router.overlayError {
                FullScreenErrorOverlay(error: err) {
                    router.clearError()
                }
                .zIndex(9999)
            }
        }
        .environmentObject(router)
        .sheet(item: $router.sheet) { sheet in
            switch sheet {
            case .infoDetail(let article):
                NavigationStack {
                    InfoDetailView(article: article, showsBackButton: true)
                }
            }
        }
        .alert(item: $router.confirmation) { c in
            if c.isDestructive {
                return Alert(
                    title: Text(c.title),
                    message: Text(c.message),
                    primaryButton: .destructive(Text(c.confirmTitle), action: {
                        c.onConfirm()
                        router.clearConfirmation()
                    }),
                    secondaryButton: .cancel(Text(c.cancelTitle), action: {
                        router.clearConfirmation()
                    })
                )
            } else {
                return Alert(
                    title: Text(c.title),
                    message: Text(c.message),
                    primaryButton: .default(Text(c.confirmTitle), action: {
                        c.onConfirm()
                        router.clearConfirmation()
                    }),
                    secondaryButton: .cancel(Text(c.cancelTitle), action: {
                        router.clearConfirmation()
                    })
                )
            }
        }
    }

    @ViewBuilder
    private func overlayView(for overlay: AppOverlay) -> some View {
        let isPresented = Binding<Bool>(
            get: { router.overlay != nil },
            set: { newValue in
                if !newValue { router.dismissOverlay() }
            }
        )

        switch overlay {
        case .barcode(let barcodeValue, let digitsText, let title, let message):
            HomeOverlay(isPresented: isPresented) {
                BarcodeOverlayContent(
                    barcodeValue: barcodeValue,
                    digitsText: digitsText,
                    title: title,
                    message: message
                )
            }
            .maxScreenBrightnessWhilePresented(isPresented: isPresented)

        case .rules(let title, let subtitle, let bodyText):
            HomeOverlay(isPresented: isPresented) {
                RulesOverlayContent(
                    title: title,
                    subtitle: subtitle,
                    bodyText: bodyText
                )
            }
        }
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
            RegistrationFlowView(
                vm: registrationVM,
                onBackToWelcome: { router.modalPop() },
                onDone: { phone in
                    session.signIn(phone: phone)
                    router.dismissModal()
                }
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
}
