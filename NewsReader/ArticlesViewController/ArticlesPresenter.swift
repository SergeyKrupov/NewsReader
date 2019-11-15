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

    // MARK: - ArticlesPresenterProtocol
    func numberOfArticles() -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func article(at indexPath: IndexPath) -> ArticleObject {
        fetchedResultsController.object(at: indexPath)
    }

    func search(query: String) {
        performSearch(query: query)
    }

    func didFinishLoading() {
        try? self.fetchedResultsController.performFetch()
        view?.reloadTable()
    }

    func willDisplayArticle(at indexPath: IndexPath) {
        if indexPath.row + 1 == numberOfArticles() {
            loadNextPage()
        }
    }

    // MARK: - Private
    enum Action {
        case none, search, loadingNextPage
    }

    private let newsService: NewsApiService
    private let container: PersistentContainer
    private let pageSize = 20
    private let context: NSManagedObjectContext
    private let canceller = Canceller()

    private weak var view: ArticlesViewProtocol?
    private var token: NSObjectProtocol?
    private var performingAction: Action = .none
    private lazy var fetchedResultsController: NSFetchedResultsController<ArticleObject> = {
        let request: NSFetchRequest<ArticleObject> = ArticleObject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ArticleObject.index, ascending: true)]
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: self.container.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()

    private func performSearch(query: String) {
        performingAction = .search
        let request = EverythingRequest(request: query, pageSize: pageSize)
        canceller << newsService.requestEverything(request) { [weak self] result in
            assert(Thread.isMainThread)
            guard let `self` = self else {
                return
            }

            self.performingAction = .none
            guard let response = try? result.get() else {
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
                    articleObject.title = article.title
                    articleObject.index = Int32(offset)
                }

                try? context.save()
            }
        }
    }

    private func loadNextPage() {
        assert(Thread.isMainThread)
        guard performingAction == .none else {
            return
        }

        performingAction = .loadingNextPage
        let requestObject = self.container.requestObject(from: container.viewContext)
        let query = requestObject.query!
        let page = requestObject.fetchedPages
        let request = EverythingRequest(request: query, pageSize: self.pageSize, page: Int(page))
        canceller << self.newsService.requestEverything(request) { [weak self] result in
            assert(Thread.isMainThread)
            guard let `self` = self else {
                return
            }

            self.performingAction = .none
            guard let response = try? result.get() else {
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
                    articleObject.title = article.title
                    articleObject.index = index + Int32(offset)
                }

                try? context.save()
            }
        }
    }
}
