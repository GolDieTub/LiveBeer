//
//  InfoView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct InfoView: View {
    private let leftPadding: CGFloat = 19
    private let rightPadding: CGFloat = 24
    private let cardHeight: CGFloat = 96
    private let imageInset: CGFloat = 16

    @EnvironmentObject private var newsStore: NewsFeedStore
    @State private var selectedKind: InfoFeedKind = .promos
    @State private var promos: [InfoArticle] = InfoPromoFactory.promos()
    @State private var presentedArticle: InfoArticle?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    Image("bg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width,
                               height: geo.size.height * 0.28,
                               alignment: .bottom)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                        .allowsHitTesting(false)

                    Spacer()
                }

                VStack(spacing: 12) {
                    header
                    content
                }
                .padding(.top, 8)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .task { await newsStore.ensureInitialLoaded() }
            .sheet(item: $presentedArticle) { article in
                NavigationStack {
                    InfoDetailView(article: article, showsBackButton: true)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Информация")
                .font(.system(size: 28, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker("", selection: $selectedKind) {
                ForEach(InfoFeedKind.allCases) { kind in
                    Text(kind.rawValue).tag(kind)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.leading, leftPadding)
        .padding(.trailing, rightPadding)
    }

    private var content: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        Color.clear.frame(height: 0).id("TOP")

                        if selectedKind == .news {
                            if newsStore.isLoadingInitial && newsStore.articles.isEmpty {
                                GrayLoader().padding(.top, 18)
                            } else {
                                if let err = newsStore.errorText {
                                    Text(err)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                ForEach(newsStore.articles) { article in
                                    Button {
                                        presentedArticle = article
                                    } label: {
                                        InfoCardView(article: article, cardHeight: cardHeight, imageInset: imageInset)
                                    }
                                    .buttonStyle(.plain)
                                    .task(id: article.id) {
                                        newsStore.loadMoreIfNeeded(current: article)
                                    }
                                }

                                if newsStore.isLoadingMore {
                                    GrayLoader().padding(.vertical, 10)
                                }
                            }
                        } else {
                            ForEach(promos) { article in
                                Button {
                                    presentedArticle = article
                                } label: {
                                    InfoCardView(article: article, cardHeight: cardHeight, imageInset: imageInset)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 18)
                }
                .scrollIndicators(.hidden)
                .safeAreaPadding(.leading, leftPadding)
                .safeAreaPadding(.trailing, rightPadding)
                .refreshable {
                    if selectedKind == .news {
                        await newsStore.refresh()
                        withAnimation(.easeInOut) { proxy.scrollTo("TOP", anchor: .top) }
                    } else {
                        promos = InfoPromoFactory.promos()
                        withAnimation(.easeInOut) { proxy.scrollTo("TOP", anchor: .top) }
                    }
                }
            }

            if selectedKind == .news, let t = newsStore.bannerText {
                Text(t)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.top, 6)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: t)
            }
        }
    }
}

private struct InfoCardView: View {
    let article: InfoArticle
    let cardHeight: CGFloat
    let imageInset: CGFloat

    var body: some View {
        let imageSize = max(0, cardHeight - imageInset * 2)

        HStack(spacing: 12) {
            RemoteImageView(url: article.imageURL, cornerRadius: 10, fill: true)
                .frame(width: imageSize, height: imageSize)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(article.date, format: .dateTime.day().month().year())
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.65))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.vertical, imageInset)
        .padding(.leading, imageInset)
        .padding(.trailing, 12)
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(Color(hex: 0xFFE100))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct GrayLoader: View {
    var body: some View {
        ProgressView()
            .tint(Color.gray.opacity(0.75))
            .scaleEffect(1.1)
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
