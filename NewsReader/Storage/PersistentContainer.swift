//
//  PersistentContainer.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import CoreData

final class PersistentContainer: NSPersistentContainer {

    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
        backgroundContext = newBackgroundContext()
    }

    private(set) var backgroundContext: NSManagedObjectContext!

    func requestObject(from context: NSManagedObjectContext) -> RequestObject {
        let request: NSFetchRequest<RequestObject> = RequestObject.fetchRequest()
        request.fetchLimit = 1
        guard let objects = try? context.fetch(request), let fetched = objects.first else {
            return RequestObject(context: context)
        }
        return fetched
    }

    func dropAllArticles(from context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSFetchRequestResult> = ArticleObject.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? persistentStoreCoordinator.execute(batchDelete, with: context)
    }

    func storeArticles(from response: EverythingResponse, request: EverythingRequest) {
        backgroundContext.perform { [context = backgroundContext!] in
            let requestObject = self.requestObject(from: context)

            let page = request.page ?? 0
            if page == 0 {
                // Reloading
                self.dropAllArticles(from: context)
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

            try? context.save()
        }
    }
}
