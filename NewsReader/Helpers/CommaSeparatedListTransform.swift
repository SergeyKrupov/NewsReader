//
//  CommaSeparatedListTransform.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 16.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import ObjectMapper

struct CommaSeparatedListTransform: TransformType {
    typealias Object = [String]
    typealias JSON = String

    func transformFromJSON(_ value: Any?) -> Object? {
        guard let nonNilValue = value, let string = nonNilValue as? String else {
            return nil
        }
        return string.components(separatedBy: ",")
    }

    func transformToJSON(_ value: Object?) -> JSON? {
        value.map { $0.joined(separator: ",") }
    }
}
