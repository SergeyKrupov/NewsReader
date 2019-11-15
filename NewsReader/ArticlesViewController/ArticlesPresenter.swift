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
    func setQueryText(_ text: String?)
}

final class ArticlesPresenter: ArticlesPresenterProtocol {

    internal init(view: ArticlesViewProtocol?, newsService: NewsApiService, container: PersistentContainer) {
        self.view = view
        self.newsService = newsService
        self.container = container

        let context = container.backgroundContext

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
        let query = container.requestObject(from: container.viewContext).query
        view?.setQueryText(query)
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
        let request = EverythingRequest(query: query, pageSize: pageSize)
        canceller << newsService.requestEverything(request) { [weak self] result in
            assert(Thread.isMainThread)
            guard let `self` = self else {
                return
            }

            self.performingAction = .none
            guard let response = try? result.get() else {
                return
            }

            self.container.storeArticles(from: response, request: request)
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
        let request = EverythingRequest(query: query, pageSize: self.pageSize, page: Int(page))
        canceller << self.newsService.requestEverything(request) { [weak self] result in
            assert(Thread.isMainThread)
            guard let `self` = self else {
                return
            }

            self.performingAction = .none
            guard let response = try? result.get() else {
                return
            }

            self.container.storeArticles(from: response, request: request)
        }
    }
}
