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
    var searchHistoryRelay: BehaviorRelay<[SearchHistory]> { get }
    var searchingRelay: BehaviorRelay<String?> { get }
    var searchResultRelay: BehaviorRelay<[Post]?> { get }
    
    func getSearchBarPlaceHolder() -> String
    func searchBarDidChanged(text: String)
    func searchPostList(search: String, searchTarget: SearchTarget)
}

final class SearchViewModel: SearchViewModelProtocol {
    
//    let searchHistoryRelay: BehaviorRelay<[SearchHistory]> = .init(value: [.init(searchRecord: .init(searchTarget: .all, keyword: "abc"), createdDateTime: .init()), .init(searchRecord: .init(searchTarget: .contents, keyword: "diji"), createdDateTime: .init())])
    let searchHistoryRelay: BehaviorRelay<[SearchHistory]> = .init(value: [])
    let searchingRelay: BehaviorRelay<String?> = .init(value: nil)
    let searchResultRelay: BehaviorRelay<[Post]?> = .init(value: nil)
    
    var currentSearchState: SearchState = .searchHistory
    
    // MARK: - Initialize
    private let board: Board
    private let noticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol
    
    init(board: Board,
         noticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol) {
        self.board = board
        self.noticeBoardAPIFetcher = noticeBoardAPIFetcher
    }
    
    func getSearchBarPlaceHolder() -> String {
        return "\(board.displayName)에서 검색"
    }
    
    func searchBarDidChanged(text: String) {
        if text.count == 0 {
            currentSearchState = .searchHistory
            searchHistoryRelay.accept(searchHistoryRelay.value)
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
}
