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
        container.register(PersistentContainer.self) { _ in
            let bundle = Bundle(for: type(of: self))
            guard let url = bundle.url(forResource: "Articles", withExtension: "momd"),
                let model = NSManagedObjectModel(contentsOf: url) else {
                    fatalError("Ошибка конфигурации стэка CoreData")
            }
            return PersistentContainer(name: "Articles", managedObjectModel: model)
        }
        .inObjectScope(.container)
    }
}
