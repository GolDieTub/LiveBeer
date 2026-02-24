//
//  BarcodeDigitsMaskFormatter.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import Foundation

enum BarcodeDigitsMaskFormatter {
    static func maskedLine(from input: String) -> String {
        let s = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return "x||xxxxxx||xxxxxx||" }

        let digitsOnly = s.filter { $0.isNumber }
        if digitsOnly.isEmpty { return "x||xxxxxx||xxxxxx||" }

        let tail = String(digitsOnly.suffix(12))
        let g1 = String(tail.prefix(6))
        let g2 = String(tail.dropFirst(6).prefix(6))

        return "x||\(String(repeating: "x", count: max(1, g1.count)))||\(String(repeating: "x", count: max(1, g2.count)))||"
    }
}
