//
//  AuthService.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    private var codesByPhone: [String: String] = [:]

    func normalizePhone(_ raw: String) -> String {
        let digits = raw.filter { $0.isNumber }
        if digits.hasPrefix("7") { return "+\(digits)" }
        if digits.hasPrefix("8") { return "+7" + digits.dropFirst() }
        if raw.hasPrefix("+") { return raw }
        return "+\(digits)"
    }

    func requestCode(for rawPhone: String) -> (phone: String, code: String) {
        let phone = normalizePhone(rawPhone)
        let code = String(Int.random(in: 1000...9999))
        codesByPhone[phone] = code
        return (phone, code)
    }

    func sendCodeStub(to phone: String, code: String) {
    }

    func verify(phone rawPhone: String, code: String) -> Bool {
        let phone = normalizePhone(rawPhone)
        return codesByPhone[phone] == code
    }
}
