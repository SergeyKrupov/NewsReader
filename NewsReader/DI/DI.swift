//
//  DI.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Swinject

let container: Container = { () -> Container in
    let container = Container()
    NewsApiServiceAssembly().assemble(container: container)
    ArticlesAssembly().assemble(container: container)
    return container
}()
