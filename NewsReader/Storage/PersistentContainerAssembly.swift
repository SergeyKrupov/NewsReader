//
//  PersistentContainerAssembly.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import CoreData
import Swinject

final class PersistentContainerAssembly: Assembly {

    func assemble(container: Container) {
        container.register(NSPersistentContainer.self) { _ in
            NSPersistentContainer(name: "Articles")
        }
        .inObjectScope(.container)
    }
}
