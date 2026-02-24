//
//  BarcodePlate.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct BarcodePlate: View {
    let payload: String
    let digitsText: String

    var body: some View {
        VStack(spacing: 10) {
            BarcodeView(payload: payload)
                .frame(height: 64)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(digitsText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.black.opacity(0.9))
                .tracking(2)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 0.6, y: 0.6)
    }
}
