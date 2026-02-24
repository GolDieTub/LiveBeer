//
//  NewsMiniCard.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct NewsMiniCard: View {
    let article: InfoArticle

    private var badgeAssetName: String {
        switch article.kind {
        case .promos: return "discount"
        case .news: return "news"
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.brandYellow)

            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineSpacing(5.6)
                    .foregroundStyle(.black)
                    .lineLimit(3)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                Text(article.date.formatted(.dateTime.day().month().year()))
                    .font(.system(size: 12, weight: .regular))
                    .tracking(-0.24)
                    .foregroundStyle(.black.opacity(0.65))
                    .padding(.horizontal, 16)

                Spacer(minLength: 0)
            }
        }
        .frame(width: 138, height: 132)
        .overlay(alignment: .bottomTrailing) {
            Image(badgeAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .allowsHitTesting(false)
        }
        .compositingGroup()
        .clipped(antialiased: true)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            Image(badgeAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .allowsHitTesting(false)
        }
    }
}
