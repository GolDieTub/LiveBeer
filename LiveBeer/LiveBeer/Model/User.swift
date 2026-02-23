//
//  User.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation

struct User: Codable, Hashable, Identifiable {
    var id: String { phone }
    let phone: String
    let name: String
    let birthDate: String
    let createdAt: Date
}
