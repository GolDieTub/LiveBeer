//
//  PhoneEntryViewModel.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

@MainActor
final class PhoneEntryViewModel: ObservableObject {
    @Published var phone: String = "+7"
    @Published var phoneError: String? = nil
    @Published var isInvalid: Bool = false
    @Published var shakeTrigger: CGFloat = 0

    private var isApplyingPhone: Bool = false

    private static let countryDigit: Character = "7"
    private static let totalDigits: Int = 11

    var canSubmit: Bool {
        phoneError == nil && phone.filter { $0.isNumber }.count == Self.totalDigits
    }

    func reset() {
        phone = "+7"
        phoneError = nil
        isInvalid = false
    }

    func validate() -> Bool {
        phoneError = nil

        let digits = phone.filter { $0.isNumber }
        if digits.count != Self.totalDigits {
            phoneError = "Введите номер полностью"
            showInvalid()
            return false
        }

        return true
    }

    func showInvalid() {
        isInvalid = true
        withAnimation(.default) { shakeTrigger += 1 }
    }

    func clearInvalid() {
        isInvalid = false
    }

    func setPhone(_ input: String) {
        guard !isApplyingPhone else { return }
        isApplyingPhone = true
        defer { isApplyingPhone = false }

        var digits = input.filter { $0.isNumber }

        if digits.isEmpty {
            phone = "+7"
            return
        }

        if digits.first != Self.countryDigit {
            digits = String(Self.countryDigit) + digits
        }

        if digits.count > Self.totalDigits {
            digits = String(digits.prefix(Self.totalDigits))
        }

        let after7 = String(digits.dropFirst(1))
        let formatted = formatPhone(digits: after7)

        if phone != formatted {
            phone = formatted
        }
    }

    private func formatPhone(digits: String) -> String {
        let d = Array(digits)
        let count = d.count

        if count == 0 { return "+7" }

        var result = "+7 ("
        result += String(d.prefix(min(3, count)))

        if count <= 3 {
            return result
        }

        result += ") "
        result += String(d.dropFirst(3).prefix(min(3, count - 3)))

        if count <= 6 { return result }

        result += " "
        result += String(d.dropFirst(6).prefix(min(2, count - 6)))

        if count <= 8 { return result }

        result += " "
        result += String(d.dropFirst(8).prefix(min(2, count - 8)))

        return result
    }
}
