//
//  RemoteImageLoader.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    var cornerRadius: CGFloat = 12
    var fill: Bool = true

    var body: some View {
        ZStack {
            if let url {
                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: fill ? .fill : .fit)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.black.opacity(0.08))

            Image(systemName: "photo")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.35))
        }
    }
}
