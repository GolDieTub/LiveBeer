//
//  BarcodeOverlayContent.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct BarcodeOverlayContent: View {
    let barcodeValue: String
    let digitsText: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            BarcodePlate(payload: barcodeValue, digitsText: digitsText)
                .clipShape(
                    RoundedCorners(tl: 10, tr: 10, bl: 10, br: 10)
                )
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.78))

                Text(message)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
        }
    }
}
