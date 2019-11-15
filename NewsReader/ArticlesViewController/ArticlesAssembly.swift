//
//  ArticlesAssembly.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Swinject

final class ArticlesAssembly: Assembly {

    func assemble(container: Container) {

        container.register(ArticlesViewController.self) { resolver in
            let view = ArticlesViewController()
            let presenter = ArticlesPresenter(
                view: view,
                newsService: resolver.resolve(NewsApiService.self)!,
                container: resolver.resolve(PersistentContainer.self)!
            )

            view.presenter = presenter
            return view
        }
    }
}
