//
//  ProfileFormState.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

@MainActor
final class ProfileFormState: ObservableObject {
    @Published var name: String = ""
    @Published var birthDateString: String = ""

    @Published var nameError: String? = nil
    @Published var birthError: String? = nil
    @Published var isInvalid: Bool = false

    @Published var nameShake: CGFloat = 0
    @Published var birthShake: CGFloat = 0

    func apply(user: User?) {
        name = user?.name ?? ""
        birthDateString = user?.birthDate ?? ""
        clearValidation()
    }

    func clearValidation() {
        nameError = nil
        birthError = nil
        isInvalid = false
    }

    func onNameChanged() {
        nameError = nil
        if isInvalid { isInvalid = false }
    }

    func onBirthChanged() {
        birthError = nil
        if isInvalid { isInvalid = false }
    }

    func hasChanges(comparedTo user: User?) -> Bool {
        guard let user else { return false }
        return name != user.name || birthDateString != user.birthDate
    }

    func validate(router: AppRouter) -> Bool {
        var ok = true

        if let err = ProfileFormValidator.validateName(name) {
            nameError = err
            nameShake += 1
            ok = false
        } else {
            nameError = nil
        }

        let res = ProfileFormValidator.validateBirthDateString(birthDateString, formatter: Self.birthFormatter)
        if let err = res.error {
            birthError = err
            birthShake += 1
            ok = false
        } else {
            birthError = nil
        }

        if res.under18 {
            router.showError(
                title: "Доступ ограничен",
                message: "Аккаунт доступен только пользователям старше 18 лет.",
                buttonTitle: "Понятно"
            )
        }

        isInvalid = !ok
        return ok
    }

    func makeUpdatedUser(from original: User) -> User {
        User(
            phone: original.phone,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            birthDate: birthDateString.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: original.createdAt
        )
    }

    func setBirth(from date: Date) {
        birthDateString = Self.birthFormatter.string(from: date)
        onBirthChanged()
    }

    func parseBirthOrNow() -> Date {
        Self.birthFormatter.date(from: birthDateString) ?? Date()
    }

    static let birthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.timeZone = .current
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()
}

enum ProfileFormValidator {
    static func validateName(_ raw: String) -> String? {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty { return "Введите имя" }
        if name.count < 2 { return "Имя должно быть не короче 2 символов" }
        return nil
    }

    static func validateBirthDateString(_ raw: String, formatter: DateFormatter) -> (error: String?, under18: Bool) {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return ("Укажите дату рождения", false) }
        guard let date = formatter.date(from: s) else { return ("Некорректная дата", false) }

        let age = ageYears(from: date, to: Date())
        if age < 18 { return ("Вам должно быть 18 лет или больше", true) }
        return (nil, false)
    }

    static func ageYears(from birth: Date, to now: Date) -> Int {
        Calendar.current.dateComponents([.year], from: birth, to: now).year ?? 0
    }
}
