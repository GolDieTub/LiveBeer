//
//  InfoDetailView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct InfoDetailView: View {
    private let leftPadding: CGFloat = 24
    private let rightPadding: CGFloat = 19

    let article: InfoArticle
    let showsBackButton: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(article.title)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 10) {
                        pill(kindText)
                        pill(article.date.formatted(.dateTime.day().month().year()))
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let url = article.imageURL {
                        RemoteImageView(url: url, cornerRadius: 16, fill: true)
                            .frame(width: max(0, geo.size.width - leftPadding - rightPadding), height: 220)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    Text(article.body)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if article.kind == .news, let source = article.sourceURL {
                        Link(destination: source) {
                            Text("Перейти к источнику")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: 0xFFE100))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.top, 6)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 22)
                .padding(.leading, leftPadding)
                .padding(.trailing, rightPadding)
                .frame(width: geo.size.width, alignment: .topLeading)
                .clipped()
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showsBackButton {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Назад")
                            }
                        }
                    }
                }
            }
        }
    }

    private var kindText: String {
        article.kind == .news ? "Новости" : "Акции"
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: 0xFFE100))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private extension Color {
    init(hex: Int, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
