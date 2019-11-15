//
//  ArticlesPresenter.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import CoreData

protocol ArticlesViewProtocol: class {

}

final class ArticlesPresenter: ArticlesPresenterProtocol {

    internal init(view: ArticlesViewProtocol?, newsService: NewsApiService, persistentContainer: PersistentContainer) {
        self.view = view
        self.newsService = newsService
        self.persistentContainer = persistentContainer
    }

    // MARK: - ArticlesPresenterProtocol
    var numberOfArticles: Int = 0

    func article(at indexPath: IndexPath) -> ArticleObject {
        fatalError()
    }

    // MARK: - Private
    private weak var view: ArticlesViewProtocol?
    private let newsService: NewsApiService
    private let persistentContainer: PersistentContainer
}
