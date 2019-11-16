//
//  AppDelegate.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let persistentContainer = container.resolve(NSPersistentContainer.self)!
        persistentContainer.loadPersistentStores { _, error in
            assert(error == nil)
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = container.resolve(ArticlesViewController.self)
        window?.makeKeyAndVisible()

        return true
    }
}
