//
//  ArticlesPresenter.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import CoreData
import Moya

protocol ArticlesViewProtocol: class {

    func reloadTable()
}

final class ArticlesPresenter: ArticlesPresenterProtocol {

    internal init(view: ArticlesViewProtocol?, newsService: NewsApiService, container: PersistentContainer) {
        self.view = view
        self.newsService = newsService
        self.container = container

        context = container.newBackgroundContext()

        let center = NotificationCenter.default
        token = center.addObserver(forName: .NSManagedObjectContextDidSave, object: context, queue: OperationQueue.main) { [weak self] _ in
            guard let `self` = self else {
                return
            }

            try? self.fetchedResultsController.performFetch()
            self.view?.reloadTable()
        }
    }

    deinit {
        requestCancellable?.cancel()
    }

    // MARK: - ArticlesPresenterProtocol
    var numberOfArticles: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func article(at indexPath: IndexPath) -> ArticleObject {
        fetchedResultsController.object(at: indexPath)
    }

    func search(query: String, ignoreCache: Bool) {
        searchIgnoringCache(query: query)
    }

    func didFinishLoading() {
        try? self.fetchedResultsController.performFetch()
        view?.reloadTable()
    }

    // MARK: - Private
    private weak var view: ArticlesViewProtocol?
    private let newsService: NewsApiService
    private let container: PersistentContainer

    private let context: NSManagedObjectContext
    private var requestCancellable: Cancellable?
    private var token: NSObjectProtocol?
    private lazy var fetchedResultsController: NSFetchedResultsController<ArticleObject> = {
        let request: NSFetchRequest<ArticleObject> = ArticleObject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ArticleObject.index, ascending: true)]
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: self.container.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()

    private func searchIgnoringCache(query: String) {
        let request = EverythingRequest(request: query)
        requestCancellable?.cancel()
        requestCancellable = newsService.requestEverything(request) { [weak self] result in
            guard let `self` = self, let response = try? result.get() else {
                return
            }

            self.context.perform { [context = self.context, container = self.container] in

                container.dropAllArticles(from: context)

                let requestObject = container.requestObject(from: context)
                requestObject.query = query
                requestObject.totalArticles = Int32(response.totalResults)

                for (offset, article) in response.articles.enumerated() {
                    let articleObject = ArticleObject(context: context)
                    articleObject.articleDescription = article.description
                    articleObject.author = article.author
                    articleObject.content = article.content
                    articleObject.imageURL = article.urlToImage
                    articleObject.publicationDate = article.publishedAt
                    articleObject.index = Int32(offset)
                }

                try? context.save()
            }
        }
    }
}
