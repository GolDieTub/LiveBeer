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

    private let sideInset: CGFloat = 23

    var body: some View {
        GeometryReader { geo in
            let innerW = max(0, geo.size.width - sideInset * 2)

            VStack(spacing: 8) {
                BarcodeView(payload: payload, quietSpace: 2)
                    .frame(width: innerW, height: 60)

                SpacedDigitsText(text: digitsText)
                    .frame(width: innerW)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .padding(.top, 32)
            .padding(.bottom, 16)
        }
        .frame(height: 138)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedCorners(tl: 0, tr: 0, bl: 18, br: 18))
    }
}

struct SpacedDigitsText: View {
    let text: String

    var body: some View {
        GeometryReader { geo in
            let chars = Array(text)
            let count = max(1, chars.count)
            let cellW = geo.size.width / CGFloat(count)

            HStack(spacing: 0) {
                ForEach(chars.indices, id: \.self) { i in
                    Text(String(chars[i]))
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.black)
                        .monospacedDigit()
                        .frame(width: cellW, alignment: .center)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: 20)
    }
}
