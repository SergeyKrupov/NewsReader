//
//  NewsApiService.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Moya
import ObjectMapper

enum NewsApiServiceError: Error {
    case internalInconsistency
    case unexpectedResponse
    case apiError(code: String, message: String)
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

                let baseResponse = BaseResponse(JSON: json)

                switch baseResponse {
                case let response as EverythingResponse:
                    completion(.success(response))
                case let response as ErrorResponse:
                    throw NewsApiServiceError.apiError(code: response.code, message: response.message)
                default:
                    throw NewsApiServiceError.unexpectedResponse
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private
    private let provider: MoyaProvider<NewsApi>
    private let queue: DispatchQueue
}
