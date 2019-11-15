//
//  ContentDownloadManager.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import CoreData

protocol ContentDownloadManager {

}

// TODO: Notification

final class ContentDownloadManagerImpl: ContentDownloadManager {

    init(container: NSPersistentContainer, service: NewsApiService) {
        self.container = container
        self.service = service
    }

    // FIXME: возможность нескольких запросов
    func search(query: String, completion: @escaping (Error?) -> Void) {
        let request = EverythingRequest(request: query)
        service.requestEverything(request) { [container] result in
            do {
                let response = try result.get()
                container.performBackgroundTask { context in
                    //response.
                }
            } catch {
                completion(error)
            }
        }
    }

    func loadNextPage(completion: @escaping (Error?) -> Void) {

    }

    // MARK: - Private
    private let container: NSPersistentContainer
    private let service: NewsApiService
}
