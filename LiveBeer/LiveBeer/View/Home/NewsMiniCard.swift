//
//  NewsMiniCard.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct NewsMiniCard: View {
    let article: InfoArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(3)

            Text(article.date.formatted(.dateTime.day().month().year()))
                .font(.system(size: 12))
                .foregroundStyle(.black.opacity(0.65))
        }
        .padding(12)
        .frame(width: 180, height: 120, alignment: .topLeading)
        .background(Color.yellow)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
