//
//  ViewController.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 14.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import Swinject
import UIKit

// TODO: remove
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let service = container.resolve(NewsApiService.self)!
        let request = EverythingRequest(request: "bitcoin")
        service.requestEverything(request) { result in
            debugPrint("response: \(result)")
        }
    }

    private lazy var container: Container = {
        let container = Container()
        let assembly = NewsApiServiceAssembly()
        assembly.assemble(container: container)
        return container
    }()

}
