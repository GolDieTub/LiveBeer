//
//  HomeViewModel.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var phone: String? = nil
    @Published private(set) var displayName: String = "Гость"

    @Published var litersProgress: Int = 6
    @Published var litersGoal: Int = 10
    @Published var giftEveryLiters: Int = 11

    @Published var points: Int = 3017

    @Published var litersTitleText: String = "Накоплено литров"
    @Published var pointsTitleText: String = "Накоплено баллов"
    @Published var pointsBodyText: String = "Собирайте баллы\nи получайте бонусы"

    @Published var rulesTitle: String = "Правила накопления\nбаллов и литров"
    @Published var rulesSubtitle: String = "1 балл = 1 рубль"
    @Published var rulesBody: String = "Посещайте магазины сети LiveBeer и получайте процент накоплений от суммы покупки.\nОбязательно предъявите карту, до начала оплаты."

    @Published var barcodeOverlayTitle: String = "Ваш накопительный код"
    @Published var barcodeOverlayMessage: String = "Для накопления литров\nпокажите его на кассе"

    var litersProgressText: String { "\(litersProgress)/\(litersGoal)" }
    var pointsValueText: String { "\(points)" }

    var litersGridCurrent: Int { max(0, min(litersProgress, litersGridTotal)) }
    var litersGridTotal: Int { max(0, litersGoal) }

    var giftMessageText: String { "Каждый \(giftEveryLiters) литр\nв подарок" }

    var isLitersComplete: Bool {
        litersGoal > 0 && litersProgress >= litersGoal
    }

    var giftBottleAssetName: String {
        isLitersComplete ? "activeBottle" : "inactiveBottle"
    }

    var barcodeValue: String {
        let digits = (phone ?? "").filter { $0.isNumber }
        if digits.isEmpty { return "0000000000000" }
        if digits.count == 13 { return digits }
        if digits.count > 13 { return String(digits.suffix(13)) }
        return String(repeating: "0", count: 13 - digits.count) + digits
    }

    var barcodeDigitsText: String {
        barcodeValue.map(String.init).joined(separator: " ")
    }

    func syncFromSession(_ session: SessionManager) {
        phone = session.currentUserPhone
        resolveDisplayName()
    }

    func refresh() async {
        resolveDisplayName()
    }

    func setPointsBody(_ text: String) {
        pointsBodyText = text
    }

    func setLitersTexts(title: String) {
        litersTitleText = title
    }

    func setPointsTexts(title: String, body: String) {
        pointsTitleText = title
        pointsBodyText = body
    }

    func setLitersProgress(current: Int, goal: Int, giftEvery: Int) {
        litersProgress = current
        litersGoal = goal
        giftEveryLiters = giftEvery
    }

    private func resolveDisplayName() {
        guard let phone, !phone.isEmpty else {
            displayName = "Гость"
            return
        }

        if let u = UserStore.shared.user(phone: phone) {
            let candidate = u.name.trimmingCharacters(in: .whitespacesAndNewlines)
            displayName = candidate.isEmpty ? "Гость" : candidate
        } else {
            displayName = "Гость"
        }
    }
}
