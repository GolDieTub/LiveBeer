//
//  AppRoute.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation

enum AppRoute: Hashable, Identifiable {
    case welcome
    case registration
    case authFlow

    var id: String {
        switch self {
        case .welcome: return "welcome"
        case .registration: return "registration"
        case .authFlow: return "authFlow"
        }
    }
}
