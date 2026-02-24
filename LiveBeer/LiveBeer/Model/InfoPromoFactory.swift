//
//  InfoPromoFactory.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import Foundation

enum InfoPromoFactory {
    static func promos() -> [InfoArticle] {
        [
            InfoArticle(
                kind: .promos,
                title: "2+1 на крафт по пятницам",
                date: date(2026, 2, 24),
                imageURL: URL(string: "https://images.unsplash.com/photo-1551730962-e8959185d25f?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=80&w=900"),
                body: "Каждую пятницу возьми 3 бутылки крафта и заплати только за 2. Действует на ассортимент крафтовых IPA/APA и сезонные релизы."
            ),
            InfoArticle(
                kind: .promos,
                title: "-15% на пшеничное до конца недели",
                date: date(2026, 2, 24),
                imageURL: URL(string: "https://images.unsplash.com/photo-1572449807319-00eca6ab9e84?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=80&w=900"),
                body: "Скидка 15% на все сорта вайцена и витбира. Идеально к рыбе и легким закускам."
            ),
            InfoArticle(
                kind: .promos,
                title: "Дегустационный сет: 4 вкуса за спеццену",
                date: date(2026, 2, 24),
                imageURL: URL(string: "https://images.unsplash.com/photo-1642191572702-329abe6282d2?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=80&w=900"),
                body: "Собери сет из 4 разных сортов (0.33/0.5 по наличию) и получи фиксированную цену. Отличный способ попробовать новинки."
            ),
            InfoArticle(
                kind: .promos,
                title: "Счастливые часы: -20% на разливное",
                date: date(2026, 2, 24),
                imageURL: URL(string: "https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=900&q=80"),
                body: "С 16:00 до 18:00 — скидка 20% на разливное. Условия действуют ежедневно, кроме праздничных дней."
            ),
            InfoArticle(
                kind: .promos,
                title: "Комбо к пиву: снеки -10%",
                date: date(2026, 2, 24),
                imageURL: URL(string: "https://images.unsplash.com/photo-1720364187685-6ee6fcdc50c4?auto=format&fit=crop&fm=jpg&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&ixlib=rb-4.1.0&q=80&w=900"),
                body: "При покупке от 2 бутылок пива — скидка 10% на снеки: чипсы, орехи, сухарики и мясные джерки."
            )
        ]
    }

    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var c = DateComponents()
        c.year = y
        c.month = m
        c.day = d
        return Calendar.current.date(from: c) ?? Date()
    }
}
