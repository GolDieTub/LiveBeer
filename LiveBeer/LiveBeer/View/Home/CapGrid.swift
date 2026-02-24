//
//  CupGrid.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct CapGrid: View {
    let current: Int
    let total: Int
    let columns: Int
    let itemSize: CGFloat
    let spacing: CGFloat
    let activeName: String
    let inactiveName: String

    var body: some View {
        let totalSafe = max(0, total)
        let currentSafe = max(0, min(current, totalSafe))
        let cols = max(1, columns)
        let grid = Array(repeating: GridItem(.fixed(itemSize), spacing: spacing, alignment: .leading), count: cols)

        LazyVGrid(columns: grid, alignment: .leading, spacing: spacing) {
            ForEach(0..<totalSafe, id: \.self) { i in
                Image(i < currentSafe ? activeName : inactiveName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: itemSize, height: itemSize)
            }
        }
    }
}
