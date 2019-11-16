//
//  BaseResponse.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 16.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import ObjectMapper

class BaseResponse: StaticMappable {

    static func objectForMapping(map: Map) -> BaseMappable? {
        let status: String? = try? map.value("status")
        switch status {
        case "ok":
            return try? EverythingResponse(map: map)
        case "error":
            return try? ErrorResponse(map: map)
        default:
            return nil
        }
    }

    func mapping(map: Map) {
    }
}
