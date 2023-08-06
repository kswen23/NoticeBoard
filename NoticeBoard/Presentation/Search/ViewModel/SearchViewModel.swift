//
//  SearchViewModel.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation

import RxSwift
import RxRelay

enum SearchState {
    case searchHistory
    case searching
    case searchResult
}

protocol SearchViewModelProtocol {
    
    var currentSearchState: SearchState { get }
    var searchHistoryRelay: BehaviorRelay<[SearchHistoryModel]> { get }
    var searchingRelay: BehaviorRelay<String?> { get }
    var searchResultRelay: BehaviorRelay<[Post]?> { get }
    
    func getSearchBarPlaceHolder() -> String
    func searchBarDidChanged(text: String)
    func searchPostList(search: String, searchTarget: SearchTarget)
    func updateSearchHistory(search: String, searchTarget: SearchTarget)
    func deleteSearchHistoryQuery(_ model: SearchHistoryModel)
}

final class SearchViewModel: SearchViewModelProtocol {
    
    lazy var searchHistoryRelay: BehaviorRelay<[SearchHistoryModel]> = .init(value: coreDataRepository.fetchSearchHistory())
    let searchingRelay: BehaviorRelay<String?> = .init(value: nil)
    let searchResultRelay: BehaviorRelay<[Post]?> = .init(value: nil)
    
    var currentSearchState: SearchState = .searchHistory
    
    // MARK: - Initialize
    private let board: Board
    private let noticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol
    private let coreDataRepository: CoreDataRepositoryProtocol
    
    init(board: Board,
         noticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol,
         coreDataRepository: CoreDataRepositoryProtocol) {
        self.board = board
        self.noticeBoardAPIFetcher = noticeBoardAPIFetcher
        self.coreDataRepository = coreDataRepository
    }
    
    func getSearchBarPlaceHolder() -> String {
        return "\(board.displayName)에서 검색"
    }
    
    func searchBarDidChanged(text: String) {
        if text.count == 0 {
            currentSearchState = .searchHistory
            searchHistoryRelay.accept(coreDataRepository.fetchSearchHistory())
        } else {
            currentSearchState = .searching
            searchingRelay.accept(text)
        }
    }
    
    func searchPostList(search: String, searchTarget: SearchTarget) {
        Task {
            currentSearchState = .searchResult
            let searchResult = await noticeBoardAPIFetcher.fetchSearchPostList(search: search, searchTarget: searchTarget, boardID: board.boardId, offset: 0, limit: 30)
            searchResultRelay.accept(searchResult)
        }
    }
    
    func updateSearchHistory(search: String, searchTarget: SearchTarget) {
        coreDataRepository.saveSearchHistory(searchHistoryModel: .init(searchRecord: .init(searchTarget: searchTarget, keyword: search), createdDateTime: .init()))
    }
    
    func deleteSearchHistoryQuery(_ model: SearchHistoryModel) {
        coreDataRepository.deleteSearchHistory(searchHistoryModel: model)
        
        searchHistoryRelay.accept(coreDataRepository.fetchSearchHistory())
    }
}
