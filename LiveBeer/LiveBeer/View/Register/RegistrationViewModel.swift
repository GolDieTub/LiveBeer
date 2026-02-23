//
//  RegistrationViewModel.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

struct RegistrationValidationError: Error, Equatable {
    let title: String
    let message: String
    let buttonTitle: String
}

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var phone: String = "+7"
    @Published var name: String = ""
    @Published var birthDate: String = ""
    @Published var isAgreementChecked: Bool = false

    @Published var phoneError: String? = nil
    @Published var nameError: String? = nil
    @Published var birthError: String? = nil
    @Published var agreementError: String? = nil

    @Published var isInvalid: Bool = false

    @Published var phoneShake: CGFloat = 0
    @Published var nameShake: CGFloat = 0
    @Published var birthShake: CGFloat = 0
    @Published var agreementShake: CGFloat = 0

    @Published var under18Alert: RegistrationValidationError? = nil

    private var isApplyingPhone: Bool = false

    private static let countryDigit: Character = "7"
    private static let totalDigits: Int = 11

    private static let birthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.timeZone = .current
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()

    func reset() {
        phone = "+7"
        name = ""
        birthDate = ""
        isAgreementChecked = false
        clearInlineErrors()
        under18Alert = nil
        isInvalid = false
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

    func setPhone(_ input: String) {
        guard !isApplyingPhone else { return }
        isApplyingPhone = true
        defer { isApplyingPhone = false }

        var digits = input.filter { $0.isNumber }

        if digits.isEmpty {
            phone = "+7"
            if phoneError == "Номер слишком длинный" { phoneError = nil }
            if isInvalid { clearInvalid() }
            return
        }

        if digits.first != Self.countryDigit {
            digits = String(Self.countryDigit) + digits
        }

        let isTooLong = digits.count > Self.totalDigits

        if isTooLong {
            phoneError = "Номер слишком длинный"
        } else if phoneError == "Номер слишком длинный" {
            phoneError = nil
        }

        if digits.count > Self.totalDigits {
            digits = String(digits.prefix(Self.totalDigits))
        }

        let after7 = String(digits.dropFirst(1))
        let formatted = formatPhone(digits: after7)
        phone = formatted

        if isInvalid { clearInvalid() }
    }

    func validate() -> Bool {
        clearInlineErrors()
        under18Alert = nil

        var hasAnyError = false

        let phoneDigits = phone.filter { $0.isNumber }
        if phoneDigits.count != Self.totalDigits {
            phoneError = "Введите номер полностью"
            hasAnyError = true
        }

        if name.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
            nameError = "Введите имя"
            hasAnyError = true
        }

        let trimmedBirth = birthDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let birth: Date? = Self.birthFormatter.date(from: trimmedBirth)

        if birth == nil {
            birthError = "Укажите дату рождения"
            hasAnyError = true
        }

        if !isAgreementChecked {
            agreementError = "Необходимо согласие"
            hasAnyError = true
        }

        if let birth, !isAtLeast18(birthDate: birth) {
            under18Alert = RegistrationValidationError(
                title: "Регистрация недоступна",
                message: "Регистрация доступна только для пользователей старше 18 лет. Продажа и употребление алкоголя лицам младше 18 лет запрещены.",
                buttonTitle: "Понятно"
            )
            hasAnyError = true
        }

        if hasAnyError {
            showInvalid()
            return false
        }

        return true
    }

    func clearInlineErrors() {
        phoneError = nil
        nameError = nil
        birthError = nil
        agreementError = nil
    }

    func showInvalid() {
        isInvalid = true

        withAnimation(.default) {
            if phoneError != nil { phoneShake += 1 }
            if nameError != nil { nameShake += 1 }
            if birthError != nil { birthShake += 1 }
            if agreementError != nil { agreementShake += 1 }
        }
    }

    func clearInvalid() {
        isInvalid = false
    }

    private func isAtLeast18(birthDate: Date) -> Bool {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .year, value: -18, to: Date()) else { return false }
        return birthDate <= cutoff
    }
}
