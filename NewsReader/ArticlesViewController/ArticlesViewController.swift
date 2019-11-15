//
//  ArticlesViewController.swift
//  NewsReader
//
//  Created by Sergey V. Krupov on 15.11.2019.
//  Copyright © 2019 Sergey V. Krupov. All rights reserved.
//

import SnapKit
import UIKit

protocol ArticlesPresenterProtocol {
    var numberOfArticles: Int { get }

    func didFinishLoading()
    func article(at indexPath: IndexPath) -> ArticleObject
    func search(query: String, ignoreCache: Bool)
}

final class ArticlesViewController: UIViewController, ArticlesViewProtocol {

    // MARK: - Dependencies
    var presenter: ArticlesPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        view.snp.makeConstraints { make in
            make.leading.equalTo(tableView.snp.leading)
            make.trailing.equalTo(tableView.snp.trailing)
            make.top.equalTo(tableView.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(tableView.safeAreaLayoutGuide.snp.bottom)
        }

        //FIXME:
        if presenter.numberOfArticles == 0 {
            presenter.search(query: "bitcoin", ignoreCache: true)
        }

        presenter.didFinishLoading()
    }

    // MARK: - ArticlesViewProtocol

    func reloadTable() {
        tableView.reloadData()
    }

    // MARK: - Private
    private let articleCellID = "ArticleTableViewCell"

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: articleCellID)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
}

extension ArticlesViewController: UITableViewDelegate {

}

extension ArticlesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfArticles
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = presenter.article(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: articleCellID, for: indexPath) as! ArticleTableViewCell
        cell.setup(with: article)
        return cell
    }
}
