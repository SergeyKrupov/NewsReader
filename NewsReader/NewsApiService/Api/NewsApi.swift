//
//  NewsApi.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Moya

enum NewsApi {
    case everything(EverythingRequest)
}

extension NewsApi: TargetType {

    var baseURL: URL {
        URL(string: "https://newsapi.org")!
    }

    var path: String {
        switch self {
        case .everything:
            return "/v2/everything"
        }
    }

    var method: Method {
        switch self {
        case .everything:
            return .get
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case let .everything(parameters):
            return .requestParameters(parameters: parameters.toJSON(), encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        ["X-Api-Key": "8d5a82f3ee5a440a9516460aa21125cd"]
    }
}
