//
//  NoticeBoardViewController.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/01.
//

import UIKit

import Moya
import RxSwift

class NoticeBoardViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "일반 게시판"
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.sizeToFit()
        return label
    }()
    
    private lazy var menuBarButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .done, target: self, action: #selector(menuBarButtonDidTapped))
    
    @objc private func menuBarButtonDidTapped() {
        presentMenuSelectViewController()
    }
    
    private lazy var searchBarButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .done, target: self, action: #selector(menuBarButtonDidTapped))
    
    @objc private func searchBarButtonDidTapped() {
        print("b")
    }
    
    private let postTableView: UITableView = UITableView()
    private var postTableViewDataSource: UITableViewDiffableDataSource<Int, Post>?
    
    // MARK: - Initialize
    private var viewModel: NoticeBoardViewModelProtocol
    
    init(viewModel: NoticeBoardViewModelProtocol) {
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
        binding()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Layout
    private func layout() {
        layoutPostTableView()
    }
    
    private func layoutPostTableView() {
        view.addSubview(postTableView)
        postTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            postTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            postTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Binding
    private func binding() {
        bindBoardRelay()
        bindPostRelay()
    }
    
    private func bindBoardRelay() {
        viewModel.boardRelay
            .subscribe{ [weak self] board in
                
                guard let board = board else { return }
                self?.viewModel.fetchPostList(for: board)
                self?.configureTitleLabel(title: board.displayName)
            }.disposed(by: disposeBag)
    }
    
    private func bindPostRelay() {
        viewModel.postRelay
            .subscribe { [weak self] postList in
                
                guard let strongSelf = self,
                      let postList = postList else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<Int, Post>()
                snapshot.appendSections([0])
                snapshot.appendItems(postList)
                strongSelf.postTableViewDataSource?.apply(snapshot, animatingDifferences: false)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    private func configure() {
        configureNavigationItem()
        configurePostTableView()
    }
    
    private func configureNavigationItem() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItems = [menuBarButton, UIBarButtonItem(customView: titleLabel)]
        navigationItem.rightBarButtonItem = searchBarButton
    }
    
    private func configurePostTableView() {
        postTableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        postTableView.backgroundColor = .systemGray6
        postTableView.delegate = self
        postTableViewDataSource = makePostTableViewDataSource()
        postTableView.dataSource = postTableViewDataSource
    }
    
    private func configureTitleLabel(title: String) {
        titleLabel.text = title
        titleLabel.sizeToFit()
    }
    
    private func presentMenuSelectViewController() {
        guard let boardList = viewModel.boardList else { return }
            
        let menuSelectViewController = DependencyInjector.shared.makeMenuSelectViewController(boardList: boardList, parentableViewController: self)
        present(UINavigationController(rootViewController: menuSelectViewController), animated: true)
    }
}

extension NoticeBoardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.postRelay.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }
    
    private func makePostTableViewDataSource() -> UITableViewDiffableDataSource<Int, Post> {
        return UITableViewDiffableDataSource(tableView: postTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
            cell.configureCell(item: item)
            return cell
        }
    }
    
}

extension NoticeBoardViewController: MenuSelectViewControllerListener {
    func menuSelectTableViewDidSelectRowAt(indexPath: IndexPath) {
        viewModel.changeBoard(to: indexPath)
    }
    
    
}
