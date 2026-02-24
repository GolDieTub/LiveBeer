//
//  RulesPlate.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct RulesPlate: View {
    let title: String
    let subtitle: String
    let rulesBody: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(rulesBody)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Image("moreInfo")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(10)
                .background(Color.yellow)
                .clipShape(Circle())
                .shadow(radius: 1, y: 1)
                .offset(x: 10, y: -10)
        }
    }
}
