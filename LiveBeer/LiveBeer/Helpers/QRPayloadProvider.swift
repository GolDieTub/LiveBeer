//
//  QRPayloadProvider.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import Foundation

enum QRPayloadProvider {
    static func normalizedPhone(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber)
        if digits.hasPrefix("8"), digits.count == 11 {
            return "7" + digits.dropFirst()
        }
        return digits
    }
}
