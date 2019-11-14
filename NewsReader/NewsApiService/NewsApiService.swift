//
//  NewsApiService.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Moya

enum NewsApiServiceError: Error {
    case internalInconsistency
}

protocol NewsApiService {

    @discardableResult
    func requestEverything(_ request: EverythingRequest, completion: @escaping (Result<EverythingResponse, Error>) -> Void) -> Cancellable
}

final class NewsApiServiceImpl: NewsApiService {

    internal init(provider: MoyaProvider<NewsApi>, queue: DispatchQueue) {
        self.provider = provider
        self.queue = queue
    }

    // MARK: - NewsApiService
    @discardableResult
    func requestEverything(_ request: EverythingRequest, completion: @escaping (Result<EverythingResponse, Error>) -> Void) -> Cancellable {
        provider.request(.everything(request), callbackQueue: queue) { result in
            do {
                let response = try result.get()
                guard let json = try response.mapJSON(failsOnEmptyData: true) as? [String: Any] else {
                    throw NewsApiServiceError.internalInconsistency
                }
                // TODO: handle error
                let object = try EverythingResponse(JSON: json)
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private
    private let provider: MoyaProvider<NewsApi>
    private let queue: DispatchQueue
}
