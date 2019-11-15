//
//  ArticlesViewController.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import UIKit

protocol ArticlesPresenterProtocol {

}

final class ArticlesViewController: UIViewController, ArticlesViewProtocol {

    // MARK: - Dependencies
    var presenter: ArticlesPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
