//
//  LoginViewModel.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var isInvalid: Bool = false
    @Published var shakeTrigger: CGFloat = 0

    @Published private(set) var canResend: Bool = false
    @Published private(set) var resendSecondsLeft: Int = 0
    @Published private(set) var debugCode: String

    let phone: String

    private var timerCancellable: AnyCancellable?

    init(phone: String, debugCode: String) {
        self.phone = phone
        self.debugCode = debugCode
    }

    var maskedPhone: String { formatMaskedRU(phone) }

    var resendText: String { "Тестовый код: \(debugCode)" }

    var canSubmit: Bool { code.count == 4 && !isInvalid }

    var primaryButtonBackground: Color {
        canSubmit ? Color(hex: "#FFE100") : Color.black.opacity(0.08)
    }

    var primaryButtonTextColor: Color {
        canSubmit ? Color.black.opacity(0.85) : Color.black.opacity(0.35)
    }

    var resendCountdownText: String {
        let m = resendSecondsLeft / 60
        let s = resendSecondsLeft % 60
        return String(format: "%02d:%02d", m, s)
    }

    func startResendCountdown(seconds: Int) {
        stopResendCountdown()
        resendSecondsLeft = max(0, seconds)
        canResend = resendSecondsLeft == 0

        guard resendSecondsLeft > 0 else { return }

        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.resendSecondsLeft > 0 {
                    self.resendSecondsLeft -= 1
                }
                if self.resendSecondsLeft <= 0 {
                    self.resendSecondsLeft = 0
                    self.canResend = true
                    self.stopResendCountdown()
                }
            }
    }

    func stopResendCountdown() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func sanitizeCode(maxDigits: Int) {
        let filtered = code.filter { $0.isNumber }
        if filtered != code { code = filtered }
        if code.count > maxDigits { code = String(code.prefix(maxDigits)) }
    }

    func verify() -> Bool {
        let ok = AuthService.shared.verify(phone: phone, code: code)
        if !ok { showInvalid() }
        return ok
    }

    func resendCode() {
        guard canResend else { return }

        let res = AuthService.shared.requestCode(for: phone)
        AuthService.shared.sendCodeStub(to: res.phone, code: res.code)

        debugCode = res.code
        code = ""
        clearInvalid()

        canResend = false
        startResendCountdown(seconds: 60)
    }

    func showInvalid() {
        isInvalid = true
        withAnimation(.default) { shakeTrigger += 1 }
    }

    func clearInvalid() {
        isInvalid = false
    }

    private func formatMaskedRU(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }

        var d = digits
        if d.count == 11, d.first == "8" { d.removeFirst(); d = "7" + d }
        if d.count == 10 { d = "7" + d }

        guard d.count >= 11 else { return input }

        let arr = Array(d)
        let a = String(arr[1...3])
        let b = String(arr[4...6])

        return "+7 (\(a)) \(b) ** **"
    }
}
