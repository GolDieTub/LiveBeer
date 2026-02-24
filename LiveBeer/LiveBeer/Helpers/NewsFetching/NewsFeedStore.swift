//
//  NewsFeedStore.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import Foundation
import Combine

@MainActor
final class NewsFeedStore: ObservableObject {
    @Published private(set) var articles: [InfoArticle] = []
    @Published private(set) var isLoadingInitial: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var isRefreshing: Bool = false
    @Published private(set) var errorText: String?
    @Published var bannerText: String?

    private let client: NewsAPIClient
    private var page: Int = 1
    private var totalResults: Int = 0
    private var didInitialLoad: Bool = false

    init(apiKey: String) {
        self.client = NewsAPIClient(apiKey: apiKey)
    }

    var canLoadMore: Bool {
        totalResults == 0 ? true : (page * 20) <= (totalResults + 20)
    }

    func ensureInitialLoaded() async {
        guard !didInitialLoad else { return }
        didInitialLoad = true
        await loadInitial()
    }

    func loadInitial() async {
        page = 1
        totalResults = 0
        articles.removeAll()

        isLoadingInitial = true
        errorText = nil
        defer { isLoadingInitial = false }

        await loadPage(pageSize: 20, reset: true)
    }

    func refresh() async {
        guard !isLoadingInitial && !isLoadingMore else { return }
        isRefreshing = true
        errorText = nil
        defer { isRefreshing = false }

        let oldTopId = articles.first?.id

        page = 1
        totalResults = 0
        await loadPage(pageSize: 20, reset: true)

        let newTopId = articles.first?.id
        if newTopId == oldTopId {
            bannerText = "Ничего нового нет"
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                if self.bannerText == "Ничего нового нет" {
                    self.bannerText = nil
                }
            }
        }
    }

    func loadMoreIfNeeded(current item: InfoArticle) {
        guard !isLoadingInitial && !isLoadingMore && !isRefreshing else { return }
        guard item.id == articles.last?.id else { return }
        Task { await loadUntilAppended(maxPages: 4) }
    }

    private func loadUntilAppended(maxPages: Int) async {
        guard canLoadMore else { return }
        isLoadingMore = true
        errorText = nil
        defer { isLoadingMore = false }

        let beforeCount = articles.count

        var pagesTried = 0
        while pagesTried < maxPages, canLoadMore {
            let oldCount = articles.count
            await loadPage(pageSize: 20, reset: false)
            if articles.count > oldCount { break }
            pagesTried += 1
        }

        if articles.count == beforeCount {
            bannerText = "Больше новостей нет"
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                if self.bannerText == "Больше новостей нет" {
                    self.bannerText = nil
                }
            }
        }
    }

    private func loadPage(pageSize: Int, reset: Bool) async {
        do {
            let beerAny = #"(beer OR brewery OR "craft beer" OR "beer festival" OR "beer ipa" OR lager OR stout OR pilsner OR hops OR "beer brewing" OR "beer brand" OR пиво OR пивовар* OR "крафтовое пиво" OR крафт OR хмель OR "пивной")"#
            let beerInTitle = #"beer OR brewery OR "craft beer" OR lager OR stout OR pilsner OR hops OR пиво OR "крафтовое пиво" OR пивоварня OR хмель"#
            let exclude = #"NOT (MBA OR Harvard OR hockey OR FBI OR election OR war OR crypto OR stock OR Bollywood OR celebrity OR murder OR politics)"#
            let q = "\(beerAny) \(exclude)"

            let res = try await client.fetchEverything(
                query: q,
                queryInTitle: beerInTitle,
                page: page,
                pageSize: pageSize,
                language: "ru",
                sortBy: .publishedAt
            )

            totalResults = res.totalResults

            let incoming = filterBeerStrict(res.articles)
            let merged = reset ? incoming : (articles + incoming)
            articles = dedup(merged)

            page += 1
        } catch {
            errorText = (error as? LocalizedError)?.errorDescription
        }
    }

    private func filterBeerStrict(_ items: [InfoArticle]) -> [InfoArticle] {
        let beerTerms = [
            "beer", "brew", "brewery", "craft", "ipa", "lager", "stout", "pilsner", "hops",
            "пиво", "пив", "крафт", "пивовар", "хмел"
        ]
        return items.filter { a in
            let s = (a.title + " " + a.body).lowercased()
            return beerTerms.contains(where: { s.contains($0) })
        }
    }

    private func dedup(_ items: [InfoArticle]) -> [InfoArticle] {
        var seen = Set<String>()
        var out: [InfoArticle] = []
        out.reserveCapacity(items.count)

        for a in items {
            let host = a.sourceURL?.host?.lowercased() ?? ""
            let normTitle = a.title.normalizedKey()
            let day = Calendar.current.dateComponents([.year, .month, .day], from: a.date)
            let dayKey = "\(day.year ?? 0)-\(day.month ?? 0)-\(day.day ?? 0)"
            let key = "\(host)|\(dayKey)|\(normTitle)"

            if seen.contains(key) { continue }
            seen.insert(key)
            out.append(a)
        }

        return out
    }
}

private extension String {
    func normalizedKey() -> String {
        let lowered = self.lowercased()
        let stripped = lowered.replacingOccurrences(of: "[^\\p{L}\\p{N}\\s]", with: "", options: .regularExpression)
        return stripped
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
