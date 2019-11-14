//
//  Article.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Foundation
import ObjectMapper

struct Article {
    let source: Source?
    let author: String?
    let title: String
    let description: String
    let url: String
    let urlToImage: String
    let publishedAt: String
    let content: String
}

extension Article: ImmutableMappable {

    init(map: Map) throws {
        source = try? map.value("source")
        author = try? map.value("author")
        title = try map.value("title")
        description = try map.value("description")
        url = try map.value("url")
        urlToImage = try map.value("urlToImage")
        publishedAt = try map.value("publishedAt")
        content = try map.value("content")
    }
}
