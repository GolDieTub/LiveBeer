//
//  AppOverlay.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

enum AppOverlay: Identifiable, Equatable {
    case barcode(barcodeValue: String, digitsText: String, title: String, message: String)
    case rules(title: String, subtitle: String, bodyText: String)

    var id: String {
        switch self {
        case .barcode(let barcodeValue, _, _, _):
            return "barcode:\(barcodeValue)"
        case .rules(let title, _, _):
            return "rules:\(title)"
        }
    }
}
