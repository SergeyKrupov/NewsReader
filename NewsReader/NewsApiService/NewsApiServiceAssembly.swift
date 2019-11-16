//
//  NewsApiServiceAssembly.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Moya
import Swinject

final class NewsApiServiceAssembly: Assembly {

    func assemble(container: Container) {
        container.register(NewsApiService.self) { _ in
            NewsApiServiceImpl(
                provider: MoyaProvider<NewsApi>(),
                queue: .main
            )
        }
        .inObjectScope(.container)
    }
}
