//
//  Source.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Foundation
import ObjectMapper

struct Source {
    let id: String
    let name: String
}

extension Source: ImmutableMappable {

    init(map: Map) throws {
        id = try map.value("id")
        name = try map.value("name")
    }
}
