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
    func numberOfArticles() -> Int
    func article(at indexPath: IndexPath) -> ArticleObject
    func willDisplayArticle(at indexPath: IndexPath)

    func didFinishLoading()
    func search(query: String)
}

final class ArticlesViewController: UIViewController, ArticlesViewProtocol {

    // MARK: - Dependencies
    var presenter: ArticlesPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        view.addSubview(queryTextField)

        queryTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(50)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(queryTextField.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }

        presenter.didFinishLoading()
    }

    // MARK: - ArticlesViewProtocol

    func reloadTable() {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }

    // MARK: - Private
    private let articleCellID = "ArticleTableViewCell"

    private lazy var queryTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(startSearch(_:)), for: .editingDidEndOnExit)
        return textField
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: articleCellID)
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshArticles(_:)), for: .valueChanged)
        return control
    }()

    @objc
    private func refreshArticles(_ sender: UIRefreshControl) {
        guard let query = queryTextField.text, !query.isEmpty else {
            refreshControl.endRefreshing()
            return
        }
        presenter.search(query: query)
    }

    @objc
    private func startSearch(_ sender: UITextField) {
        guard let query = queryTextField.text, !query.isEmpty else {
            return
        }
        queryTextField.resignFirstResponder()
        presenter.search(query: query)
    }
}

extension ArticlesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayArticle(at: indexPath)
    }
}

extension ArticlesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfArticles()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = presenter.article(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: articleCellID, for: indexPath) as! ArticleTableViewCell
        cell.setup(with: article)
        return cell
    }
}
