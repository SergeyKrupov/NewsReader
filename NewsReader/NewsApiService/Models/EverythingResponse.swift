//
//  EverythingResponse.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Foundation
import ObjectMapper

struct EverythingResponse {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

extension EverythingResponse: ImmutableMappable {

    init(map: Map) throws {
        status = try map.value("status")
        totalResults = try map.value("totalResults")
        articles = try map.value("articles")
    }
}
