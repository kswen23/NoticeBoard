//
//  SearchViewController.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation
import UIKit

import RxSwift

final class SearchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let searchNavigationBar = CustomSearchNavigationBar()
    private let searchTableView = UITableView()
    
    
    private var searchingDataSource: UITableViewDiffableDataSource<Int, SearchTarget>?
    private var searchTableViewDataSource: UITableViewDiffableDataSource<Int, SearchHistoryModel>?
    private var searchResultTableViewDataSource: UITableViewDiffableDataSource<Int, Post>?
    
    private let emptyResultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "empty.png")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let emptyResultLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다.\n다른 검색어를 입력해 보세요."
        label.numberOfLines = 2
        label.sizeToFit()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true
        return label
    }()
    
    private let emptyResultStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.isHidden = true
        return stackView
    }()
    
    private let emptyHistoryImageView: UIView = {
        let view = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search.png")
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        view.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 171),
            imageView.heightAnchor.constraint(equalToConstant: 171),
            imageView.widthAnchor.constraint(equalToConstant: 151),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        return view
    }()
    
    private let emptyHistoryLabel: UILabel = {
        let label = UILabel()
        label.text = "게시글의 제목, 내용 또는 작성자에 포함된\n단어 또는 문장을 검색해 주세요."
        label.numberOfLines = 2
        label.sizeToFit()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true
        return label
    }()
    
    private let emptyHistoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - Initialize
    private var viewModel: SearchViewModelProtocol
    
    init(viewModel: SearchViewModelProtocol) {
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
    }
    
    // MARK: - Layout
    private func layout() {
        layoutCustomSearchNavigationBar()
        layoutSearchTableView()
        layoutEmptyResultStackView()
        layoutEmptyHistoryStackView()
    }
    
    private func layoutCustomSearchNavigationBar() {
        view.addSubview(searchNavigationBar)
        searchNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchNavigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchNavigationBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func layoutSearchTableView() {
        view.addSubview(searchTableView)
        searchTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: searchNavigationBar.bottomAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func layoutEmptyResultStackView() {
        [emptyResultImageView, emptyResultLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            emptyResultStackView.addArrangedSubview($0)
        }
        
        view.addSubview(emptyResultStackView)
        emptyResultStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyResultStackView.centerXAnchor.constraint(equalTo: searchTableView.centerXAnchor),
            emptyResultStackView.centerYAnchor.constraint(equalTo: searchTableView.centerYAnchor, constant: -50),
            emptyResultStackView.heightAnchor.constraint(equalToConstant: 300),
        ])
    }
    
    private func layoutEmptyHistoryStackView() {
        [emptyHistoryImageView, emptyHistoryLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            emptyHistoryStackView.addArrangedSubview($0)
        }
        
        view.addSubview(emptyHistoryStackView)
        emptyHistoryStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyHistoryStackView.centerXAnchor.constraint(equalTo: searchTableView.centerXAnchor),
            emptyHistoryStackView.centerYAnchor.constraint(equalTo: searchTableView.centerYAnchor, constant: -120),
        ])
    }
    
    // MARK: - Configure
    private func configure() {
        configureBackground()
        configureSearchNavigationBar()
        configureSearchTableView()
    }
    
    private func configureBackground() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .white
    }
    
    private func configureSearchNavigationBar() {
        searchNavigationBar.delegate = self
        searchNavigationBar.configureTextFieldPlaceholder(placeholder: viewModel.getSearchBarPlaceHolder())
    }
    
    private func configureSearchTableView() {
        searchTableView.backgroundColor = .systemGray6
        searchTableView.delegate = self
        searchTableView.register(SearchHistoryTableViewCell.self, forCellReuseIdentifier: SearchHistoryTableViewCell.identifier)
        searchTableView.register(SearchingTableViewCell.self, forCellReuseIdentifier: SearchingTableViewCell.identifier)
        searchTableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        searchTableView.keyboardDismissMode = .onDrag
    }
    
    // MARK: - Binding
    private func binding() {
        bindSearchHistorySubject()
        bindSearchingSubject()
        bindSearchResultRelay()
    }
    
    private func bindSearchHistorySubject() {
        viewModel.searchHistoryRelay
            .observe(on: MainScheduler.instance)
            .filter({ [weak self] _ in
                guard let strongSelf = self else { return false }
                return strongSelf.viewModel.currentSearchState == .searchHistory
            })
            .subscribe(onNext: { [weak self] searchHistory in
                
                guard let strongSelf = self else { return }
                
                strongSelf.emptyResultStackView.isHidden = true
                if searchHistory.isEmpty {
                    strongSelf.emptyHistoryStackView.isHidden = false
                } else {
                    strongSelf.emptyHistoryStackView.isHidden = true
                }
                
                strongSelf.searchTableViewDataSource = self?.makeSearchHistoryTableViewDataSource()
                
                var snapshot = NSDiffableDataSourceSnapshot<Int, SearchHistoryModel>()
                snapshot.appendSections([0])
                snapshot.appendItems(searchHistory, toSection: 0)
                strongSelf.searchTableViewDataSource?.apply(snapshot, animatingDifferences: false)

            })
            .disposed(by: disposeBag)
    }
    
    private func bindSearchingSubject() {
        
        viewModel.searchingRelay
            .observe(on: MainScheduler.instance)
            .filter({ [weak self] _ in
                guard let strongSelf = self else { return false }
                return strongSelf.viewModel.currentSearchState == .searching
            })
            .subscribe(onNext: { [weak self] searchingText in
                
                guard let strongSelf = self,
                      let searchingText = searchingText else { return }
                
                strongSelf.emptyResultStackView.isHidden = true
                strongSelf.emptyHistoryStackView.isHidden = true
                strongSelf.searchingDataSource = self?.makeSearchingTableViewDataSource(searchingText)
                var snapshot = NSDiffableDataSourceSnapshot<Int, SearchTarget>()
                snapshot.appendSections([0])
                snapshot.appendItems(SearchTarget.allCases, toSection: 0)
                strongSelf.searchingDataSource?.apply(snapshot, animatingDifferences: false)
            }).disposed(by: disposeBag)
    }
    
    private func bindSearchResultRelay() {
        viewModel.searchResultRelay
            .observe(on: MainScheduler.instance)
            .filter({ [weak self] _ in
                guard let strongSelf = self else { return false }
                return strongSelf.viewModel.currentSearchState == .searchResult
            })
            .subscribe(onNext: { [weak self] searchResult in
                
                guard let strongSelf = self,
                      let postList = searchResult else { return }
                
                strongSelf.emptyHistoryStackView.isHidden = true
                if postList.isEmpty {
                    strongSelf.emptyResultStackView.isHidden = false
                } else {
                    strongSelf.emptyResultStackView.isHidden = true
                }
                
                strongSelf.searchResultTableViewDataSource = self?.makeSearchResultTableViewDataSource()
                var snapshot = NSDiffableDataSourceSnapshot<Int, Post>()
                snapshot.appendSections([0])
                snapshot.appendItems(postList, toSection: 0)
                strongSelf.searchResultTableViewDataSource?.apply(snapshot, animatingDifferences: false)
                
                
            }).disposed(by: disposeBag)
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var search: String!
        var searchTarget: SearchTarget!
        
        switch viewModel.currentSearchState {
        case .searchHistory:
            search = viewModel.searchHistoryRelay.value[indexPath.row].searchRecord.keyword
            searchTarget = viewModel.searchHistoryRelay.value[indexPath.row].searchRecord.searchTarget
        case .searching:
            search = viewModel.searchingRelay.value
            searchTarget = getSearchingTarget(row: indexPath.row)
        case .searchResult:
            return
        }
        
        startSearching(text: search, state: .result, searchTarget: searchTarget)
    }
    
    private func startSearching(text: String, state: SearchBarState, searchTarget: SearchTarget) {
        
        searchNavigationBar.resignTextField()
        searchNavigationBar.changeSearchBarState(text: text, state: state, searchTarget: searchTarget)
        viewModel.searchPostList(search: text, searchTarget: searchTarget)
        viewModel.updateSearchHistory(search: text, searchTarget: searchTarget)
    }
    
    private func getSearchingTarget(row: Int) -> SearchTarget {
        switch row {
        case 0: return .all
        case 1: return .title
        case 2: return .contents
        case 3: return .writer
        default: fatalError()
        }
    }
    
    private func makeSearchHistoryTableViewDataSource() -> UITableViewDiffableDataSource<Int, SearchHistoryModel> {
        return UITableViewDiffableDataSource(tableView: searchTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.identifier, for: indexPath) as? SearchHistoryTableViewCell else { return UITableViewCell() }
            cell.configureCell(item: item)
            cell.delegate = self
            return cell
        }
    }
    
    private func makeSearchingTableViewDataSource(_ keyword: String) -> UITableViewDiffableDataSource<Int, SearchTarget> {
        return UITableViewDiffableDataSource(tableView: searchTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchingTableViewCell.identifier, for: indexPath) as? SearchingTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            cell.configureSearchingTableViewCell(item: item, keyword: keyword)
            return cell
        }
    }
    
    private func makeSearchResultTableViewDataSource() -> UITableViewDiffableDataSource<Int, Post> {
        return UITableViewDiffableDataSource(tableView: searchTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
            cell.configureCell(item: item)
            return cell
        }
    }
}

extension SearchViewController: CustomSearchBarDelegate {
    
    func searchBarDidBeginEditing(_ searchBar: CustomSearchNavigationBar) {
        searchBar.changeSearchBarState(state: .searching)
    }
    
    
    func searchBar(_ searchBar: CustomSearchNavigationBar, textDidChange searchText: String) {
        viewModel.searchBarDidChanged(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: CustomSearchNavigationBar) {
        popViewController()
    }
    
    private func popViewController() {
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: SearchingTableViewCellDelegate, SearchHistoryTableViewCellDelegate {
    
    func searchButtonDidTapped(cell: SearchingTableViewCell) {
        
        guard let index = searchTableView.indexPath(for: cell)?.row,
              let text = viewModel.searchingRelay.value else { return }
        
        startSearching(text: text,
                       state: .result,
                       searchTarget: SearchTarget.allCases[index])
    }
    
    func deleteButtonDidTapped(cell: SearchHistoryTableViewCell) {
        guard let index = searchTableView.indexPath(for: cell)?.row else { return }
        let searchHistoryModel = viewModel.searchHistoryRelay.value[index]
        
        viewModel.deleteSearchHistoryQuery(searchHistoryModel)
    }
}
