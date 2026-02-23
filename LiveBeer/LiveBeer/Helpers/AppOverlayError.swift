//
//  AppOverlayError.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation

struct AppOverlayError: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let buttonTitle: String
}
