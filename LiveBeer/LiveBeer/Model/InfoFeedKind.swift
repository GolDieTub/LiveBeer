//
//  InfoFeedKind.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import Foundation

enum InfoFeedKind: String, CaseIterable, Identifiable {
    case promos = "Акции"
    case news = "Новости"

    var id: String { rawValue }
}

struct InfoArticle: Identifiable, Equatable, Hashable {
    let id: UUID
    let kind: InfoFeedKind
    let title: String
    let date: Date
    let imageURL: URL?
    let body: String
    let sourceURL: URL?

    init(
        id: UUID = UUID(),
        kind: InfoFeedKind,
        title: String,
        date: Date,
        imageURL: URL?,
        body: String,
        sourceURL: URL? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.date = date
        self.imageURL = imageURL
        self.body = body
        self.sourceURL = sourceURL
    }
}
