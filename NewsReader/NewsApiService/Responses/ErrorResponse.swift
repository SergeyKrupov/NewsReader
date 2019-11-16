//
//  ErrorResponse.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 16.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import ObjectMapper

final class ErrorResponse: BaseResponse, ImmutableMappable {
    let code: String
    let message: String

    init(map: Map) throws {
        code = try map.value("code")
        message = try map.value("message")
    }
}
