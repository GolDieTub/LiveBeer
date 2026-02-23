//
//  AuthFlowView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct AuthFlowView: View {
    enum Step: Equatable {
        case phone
        case otp(phone: String, debugCode: String)
    }

    @State private var step: Step = .phone
    @State private var isForward: Bool = true
    @StateObject private var phoneVM = PhoneEntryViewModel()

    var onBackToWelcome: () -> Void
    var onDone: (_ phone: String) -> Void

    var body: some View {
        ZStack {
            switch step {
            case .phone:
                PhoneEntryView(
                    vm: phoneVM,
                    onBack: { onBackToWelcome() },
                    onNext: { phone, debugCode in
                        isForward = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            step = .otp(phone: phone, debugCode: debugCode)
                        }
                    }
                )
                .transition(stepTransition)

            case let .otp(phone, debugCode):
                LoginView(
                    vm: LoginViewModel(phone: phone, debugCode: debugCode),
                    onBack: {
                        isForward = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            step = .phone
                        }
                    },
                    onSubmit: {
                        onDone(phone)
                    }
                )
                .transition(stepTransition)
            }
        }
        .onAppear {
            step = .phone
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
}
