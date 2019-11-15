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
    }

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
}
