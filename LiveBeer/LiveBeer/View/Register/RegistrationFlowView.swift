//
//  RegistrationFlowView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct RegistrationFlowView: View {
    enum Step: Equatable {
        case form
        case otp(phone: String, debugCode: String)
    }

    @EnvironmentObject private var router: AppRouter

    @State private var step: Step = .form
    @State private var isForward: Bool = true

    @State private var pendingUser: User? = nil
    @State private var pendingPhone: String? = nil

    @StateObject var vm: RegistrationViewModel

    var onBackToWelcome: () -> Void
    var onDone: (_ phone: String) -> Void

    var body: some View {
        ZStack {
            switch step {
            case .form:
                RegistrationView(
                    vm: vm,
                    onBack: { onBackToWelcome() },
                    onSubmit: { submitRegistration() }
                )
                .transition(stepTransition)

            case let .otp(phone, debugCode):
                LoginView(
                    vm: LoginViewModel(phone: phone, debugCode: debugCode),
                    onBack: {
                        isForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            step = .form
                        }
                    },
                    onSubmit: {
                        completeRegistrationAndSignIn(phone: phone)
                    }
                )
                .transition(stepTransition)
            }
        }
        .onAppear {
            step = .form
        }
    }

    private var stepTransition: AnyTransition {
        if isForward {
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        } else {
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        }
    }

    private func submitRegistration() {
        let ok = vm.validate()

        if let alert = vm.under18Alert {
            if vm.birthError == nil { vm.birthError = "Некорректная дата рождения" }
            vm.birthShake += 1
            vm.isInvalid = true
            router.showError(title: alert.title, message: alert.message, buttonTitle: alert.buttonTitle)
            return
        }

        guard ok else { return }

        let phone = AuthService.shared.normalizePhone(vm.phone)

        if UserStore.shared.exists(phone: phone) {
            router.showError(
                title: "Регистрация невозможна",
                message: "Пользователь с таким номером уже зарегистрирован. Попробуйте войти или укажите другой номер.",
                buttonTitle: "Понятно"
            )
            vm.phoneError = vm.phoneError ?? "Номер уже зарегистрирован"
            vm.phoneShake += 1
            vm.isInvalid = true
            return
        }

        let user = User(
            phone: phone,
            name: vm.name.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: vm.birthDate.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: Date()
        )

        pendingUser = user
        pendingPhone = phone

        let res = AuthService.shared.requestCode(for: phone)
        AuthService.shared.sendCodeStub(to: res.phone, code: res.code)

        isForward = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            step = .otp(phone: res.phone, debugCode: res.code)
        }
    }

    private func completeRegistrationAndSignIn(phone: String) {
        guard let pendingPhone, pendingPhone == phone, let pendingUser else {
            router.showError(
                title: "Ошибка",
                message: "Не удалось завершить регистрацию. Попробуйте ещё раз.",
                buttonTitle: "Ок"
            )
            return
        }

        UserStore.shared.add(pendingUser)
        onDone(phone)
    }
}
