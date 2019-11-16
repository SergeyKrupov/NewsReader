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

    internal init(view: ArticlesViewProtocol?, newsService: NewsApiService, container: NSPersistentContainer) {
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

    // Ищем новости по введённому пользователем запросу
    func search(query: String) {
        performingAction = .search
        let request = EverythingRequest(query: query, pageSize: pageSize)
        canceller << newsService.requestEverything(request) { [weak self] result in
            assert(Thread.isMainThread)
            guard let `self` = self else {
                return
            }
            self.performingAction = .none
            do {
                self.storeArticles(from: try result.get(), request: request, completion: self.errorHandler)
            } catch {
                self.errorHandler(error)
            }
        }
    }

    // Завершение загрузки экрана
    func didFinishLoading() {
        let query = try? container.viewContext.requestObject().query
        view?.setQueryText(query)
        try? self.fetchedResultsController.performFetch()
        view?.reloadTable()
    }

    // Событие показа ячейки со статьёй в таблице
    func willDisplayArticle(at indexPath: IndexPath) {
        guard indexPath.row + 1 == numberOfArticles(), performingAction == .none else {
            return
        }

        let requestObject: RequestObject
        do {
            requestObject = try container.viewContext.requestObject()
        } catch {
            errorHandler(error)
            return
        }

        performingAction = .loadingNextPage
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

            self.storeArticles(from: response, request: request, completion: self.errorHandler)
        }
    }

    // MARK: - Private
    enum Action {
        case none, search, loadingNextPage
    }

    private let newsService: NewsApiService
    private let container: NSPersistentContainer
    private let pageSize = 20
    private let canceller = Canceller()

    private weak var view: ArticlesViewProtocol?
    private var context: NSManagedObjectContext!
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

    private var errorHandler: (Error?) -> Void {
        return { _ in
            // TODO:
        }
    }

    private func loadNextPage() {
        assert(Thread.isMainThread)
        guard performingAction == .none else {
            return
        }

        let requestObject: RequestObject
        do {
            requestObject = try container.viewContext.requestObject()
        } catch {
            errorHandler(error)
            return
        }

        performingAction = .loadingNextPage
        let query = requestObject.query!
        let page = requestObject.fetchedPages
        let request = EverythingRequest(query: query, pageSize: self.pageSize, page: Int(page))
        canceller << self.newsService.requestEverything(request) { [weak self] result in
            assert(Thread.isMainThread)
            guard let `self` = self else {
                return
            }
            self.performingAction = .none
            do {
                self.storeArticles(from: try result.get(), request: request, completion: self.errorHandler)
            } catch {
                self.errorHandler(error)
            }
        }
    }
}

private extension ArticlesPresenter {

    func storeArticles(from response: EverythingResponse, request: EverythingRequest, completion: @escaping (Error?) -> Void) {
        context.perform { [context = context!, coordinator = container.persistentStoreCoordinator] in
            do {
                let requestObject = try context.requestObject()
                let page = request.page ?? 0

                if page == 0 {
                    // Обновление содежримого -- нужно удалить сохранённые записи
                    let request: NSFetchRequest<NSFetchRequestResult> = ArticleObject.fetchRequest()
                    let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
                    _ = try coordinator.execute(batchDelete, with: context)
                    requestObject.fetchedArticles = 0
                }

                requestObject.query = request.query
                requestObject.totalArticles = Int32(response.totalResults)
                requestObject.fetchedArticles += Int32(response.articles.count)
                requestObject.fetchedPages = Int32(page) + 1

                let index = requestObject.fetchedArticles
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

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

private extension NSManagedObjectContext {

    func requestObject() throws -> RequestObject {
        let request: NSFetchRequest<RequestObject> = RequestObject.fetchRequest()
        request.fetchLimit = 1
        guard let objects = try? fetch(request), let fetched = objects.first else {
            return RequestObject(context: self)
        }
        return fetched
    }
}
