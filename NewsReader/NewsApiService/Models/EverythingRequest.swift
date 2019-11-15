//
//  EverythingRequest.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import ObjectMapper

struct EverythingRequest {
    var query: String?
    var qInTitle: String?
    var sources: [String]?
    var domains: [String]?
    var excludeDomains: [String]?
    var fromDate: Date?
    var toDate: Date?
    var language: Language = .ru
    var sortBy: SortBy?
    var pageSize: Int?
    var page: Int?
}

extension EverythingRequest {
    enum Language: String {
        // swiftlint:disable:next identifier_name
        case ar, de, en, es, fr, he, it, nl, no, pt, ru, se, ud, zh
    }

    enum SortBy: String {
        case relevancy, popularity, publishedAt
    }
}

extension EverythingRequest: Mappable {
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        query <- map["q"]
        qInTitle <- map["qInTitle"]
        // TODO: sources
        // TODO: domains
        // TODO: excludeDomains
        fromDate <- (map["from"], ISO8601DateTransform())
        toDate <- (map["to"], ISO8601DateTransform())
        language <- map["language"]
        sortBy <- map["sortBy"]
        pageSize <- map["pageSize"]
        page <- map["page"]
    }
}
