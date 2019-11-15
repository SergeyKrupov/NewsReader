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
        if indexPath.row + 1 == numberOfArticles {
            loadNext()
        }
        return fetchedResultsController.object(at: indexPath)
    }

    func search(query: String) {
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
    private let pageSize = 20

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
        let request = EverythingRequest(request: query, pageSize: pageSize)
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
                requestObject.fetchedArticles = Int32(response.articles.count)
                requestObject.fetchedPages = 1

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

    private func loadNext() {
        self.context.perform { [weak self] in
            guard let `self` = self else {
                return
            }

            let requestObject = self.container.requestObject(from: self.context)

            let query = requestObject.query!
            let page = requestObject.fetchedPages
            let request = EverythingRequest(request: query, pageSize: self.pageSize, page: Int(page))
            self.requestCancellable?.cancel()
            self.requestCancellable = self.newsService.requestEverything(request) { [weak self] result in
                guard let `self` = self, let response = try? result.get() else {
                    return
                }

                self.context.perform { [context = self.context, container = self.container] in

                    let requestObject = container.requestObject(from: context)
                    let index = requestObject.totalArticles

                    requestObject.query = query
                    requestObject.totalArticles += Int32(response.totalResults)
                    requestObject.fetchedArticles = Int32(response.articles.count)
                    requestObject.fetchedPages = page + 1

                    for (offset, article) in response.articles.enumerated() {
                        let articleObject = ArticleObject(context: context)
                        articleObject.articleDescription = article.description
                        articleObject.author = article.author
                        articleObject.content = article.content
                        articleObject.imageURL = article.urlToImage
                        articleObject.publicationDate = article.publishedAt
                        articleObject.index = index + Int32(offset)
                    }

                    try? context.save()
                }
            }
        }
    }
}
