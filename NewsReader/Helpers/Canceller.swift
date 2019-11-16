//
//  Canceller.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Moya

final class Canceller {

    deinit {
        cancellable?.cancel()
    }

    func setCancellable(_ cancellable: Cancellable?) {
        self.cancellable?.cancel()
        self.cancellable = cancellable
    }

    static func << (canceller: Canceller, _ cancellable: Cancellable?) {
        canceller.setCancellable(cancellable)
    }

    private var cancellable: Cancellable?
}
