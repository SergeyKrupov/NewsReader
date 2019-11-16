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
    func refreshResult()
}

final class ArticlesViewController: UIViewController, ArticlesViewProtocol {

    // MARK: - Dependencies
    var presenter: ArticlesPresenterProtocol!

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        presenter.didFinishLoading()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    // MARK: - ArticlesViewProtocol

    func reloadTable() {
        tableView.reloadData()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func setQueryText(_ text: String?) {
        navigationItem.title = text ?? emptyTitle
    }

    func presentError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Private
    private let articleCellID = "ArticleTableViewCell"
    private let emptyTitle = "Поиск новостей"

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

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        return controller
    }()

    private func setupNavigationItem() {
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.title = emptyTitle
    }

    @objc
    private func refreshArticles(_ sender: UIRefreshControl) {
        presenter.refreshResult()
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

extension ArticlesViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else {
            return
        }
        searchController.isActive = false
        presenter.search(query: query)
    }
}
