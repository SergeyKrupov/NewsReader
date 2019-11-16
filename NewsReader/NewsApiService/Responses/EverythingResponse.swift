//
//  EverythingResponse.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Foundation
import ObjectMapper

final class EverythingResponse: BaseResponse, ImmutableMappable {
    let totalResults: Int
    let articles: [Article]

    init(map: Map) throws {
         totalResults = try map.value("totalResults")
         articles = try map.value("articles")
     }
}
