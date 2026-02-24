//
//  NewsAPIClient.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import UIKit

enum NewsAPIError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case badStatus(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "API ключ отсутствует."
        case .invalidURL: return "Неверный URL."
        case .badStatus(let code): return "Ошибка сервера: \(code)."
        case .decodingFailed: return "Не удалось разобрать ответ."
        }
    }
}

struct NewsAPIClient {
    let apiKey: String
    let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    enum EverythingSortBy: String {
        case publishedAt
        case relevancy
        case popularity
    }

    struct EverythingPage {
        let articles: [InfoArticle]
        let totalResults: Int
    }

    func fetchEverything(
        query: String,
        queryInTitle: String?,
        page: Int,
        pageSize: Int,
        language: String?,
        sortBy: EverythingSortBy
    ) async throws -> EverythingPage {

        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { throw NewsAPIError.missingAPIKey }

        guard var comps = URLComponents(string: "https://newsapi.org/v2/everything") else {
            throw NewsAPIError.invalidURL
        }

        var items: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize)),
            URLQueryItem(name: "sortBy", value: sortBy.rawValue)
        ]

        if let queryInTitle, !queryInTitle.isEmpty {
            items.append(URLQueryItem(name: "qInTitle", value: queryInTitle))
        }

        if let language, !language.isEmpty {
            items.append(URLQueryItem(name: "language", value: language))
        }

        comps.queryItems = items
        guard let url = comps.url else { throw NewsAPIError.invalidURL }

        var browserComps = comps
        var browserItems = items
        browserItems.append(URLQueryItem(name: "apiKey", value: key))
        browserComps.queryItems = browserItems

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(key, forHTTPHeaderField: "X-Api-Key")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NewsAPIError.badStatus(-1)
        }
        guard (200...299).contains(http.statusCode) else {
            throw NewsAPIError.badStatus(http.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let decoded = try? decoder.decode(NewsAPIResponse.self, from: data) else {
            throw NewsAPIError.decodingFailed
        }

        let mapped = decoded.articles.compactMap { item -> InfoArticle? in
            let title = item.title?.cleanNewsText() ?? "Без названия"
            let description = item.description?.cleanNewsText()

            let body = description ?? "Откройте источник, чтобы прочитать новость полностью."

            return InfoArticle(
                kind: .news,
                title: title,
                date: item.publishedAt ?? Date(),
                imageURL: URL(string: item.urlToImage ?? ""),
                body: body,
                sourceURL: URL(string: item.url ?? "")
            )
        }

        return EverythingPage(
            articles: mapped,
            totalResults: decoded.totalResults ?? mapped.count
        )
    }
}

private struct NewsAPIResponse: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [NewsAPIArticle]
}

private struct NewsAPIArticle: Decodable {
    let title: String?
    let description: String?
    let content: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: Date?
}

private extension String {
    func cleanNewsText() -> String {
        var s = self
        s = s.replacingOccurrences(of: "\r\n", with: "\n")
        s = s.replacingOccurrences(of: "\r", with: "\n")
        s = s.replacingOccurrences(
            of: "(?:\\.{3}|…)?\\s*\\[\\+\\d+\\s*chars\\]",
            with: "",
            options: .regularExpression
        )
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
