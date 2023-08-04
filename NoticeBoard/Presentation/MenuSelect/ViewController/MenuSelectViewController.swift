//
//  MenuSelectViewController.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation
import UIKit

protocol MenuSelectViewControllerListener: NSObject {
    
    func menuSelectTableViewDidSelectRowAt(indexPath: IndexPath)
}

final class MenuSelectViewController: UIViewController {
    
    weak var parentableViewController: MenuSelectViewControllerListener?
    
    private lazy var xMarkButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(xMarkButtonDidTapped))
    
    @objc private func xMarkButtonDidTapped() {
        dismiss(animated: true)
    }
    
    private let headerTitleView: UIView = {
        let view = UIView()
        let label = UILabel()
        label.text = "게시판"
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.sizeToFit()
        let borderView = UIView()
        borderView.backgroundColor = .systemGray4
        [label, borderView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            borderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 0.7),
            borderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }()
    
    private let menuSelectTableView: UITableView = UITableView()
    
    // MARK: - Initialize
    private let viewModel: MenuSelectViewModelProtocol
    
    init(viewModel: MenuSelectViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutHeaderTitleView()
        layoutMenuSelectTableView()
    }
    
    private func layoutHeaderTitleView() {
        view.addSubview(headerTitleView)
        headerTitleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerTitleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerTitleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerTitleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerTitleView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func layoutMenuSelectTableView() {
        view.addSubview(menuSelectTableView)
        menuSelectTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuSelectTableView.topAnchor.constraint(equalTo: headerTitleView.bottomAnchor),
            menuSelectTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            menuSelectTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            menuSelectTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
        configureMenuSelectTableView()
    }
    
    private func configureNavigationItem() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = xMarkButton
    }
    
    private func configureMenuSelectTableView() {
        menuSelectTableView.register(MenuSelectTableViewCell.self, forCellReuseIdentifier: MenuSelectTableViewCell.identifier)
        menuSelectTableView.delegate = self
        menuSelectTableView.dataSource = self
        menuSelectTableView.separatorStyle = .none
    }
}

extension MenuSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.boardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuSelectTableViewCell.identifier, for: indexPath) as? MenuSelectTableViewCell else { return UITableViewCell() }
        viewModel.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        parentableViewController?.menuSelectTableViewDidSelectRowAt(indexPath: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        dismiss(animated: true)
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        55
    }
    
}
