//
//  NoticeBoardViewModel.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation
import UIKit

import RxSwift
import RxRelay

protocol NoticeBoardViewModelProtocol {
    
    var boardRelay: BehaviorRelay<Board?> { get }
    var postRelay: BehaviorRelay<[Post]?> { get }
    var boardList: [Board]? { get }
    
    func viewDidLoad()
    func changeBoard(to indexPath: IndexPath)
    func fetchPostList(for board: Board)
    func fetchNextPostList()
    func postListDidUpdated(with postList: [Post])
}

final class NoticeBoardViewModel: NoticeBoardViewModelProtocol {
    
    let boardRelay: BehaviorRelay<Board?> = .init(value: nil)
    let postRelay: BehaviorRelay<[Post]?> = .init(value: nil)
    var boardList: [Board]?
    private var currentOffset = 0
    private var hasNextPage: Bool?
    private var isFetchable: Bool?
    
    // MARK: - Initialize
    private let noticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol
    
    init(noticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol) {
        self.noticeBoardAPIFetcher = noticeBoardAPIFetcher
    }
    
    func viewDidLoad() {
        fetchBoardList()
    }
    
    func fetchBoardList() {
        Task {
            boardList = await noticeBoardAPIFetcher.fetchBoardList()
            
            guard let boardList = boardList else { return }
            
            await MainActor.run { [boardList] in
                self.boardRelay.accept(boardList[0])
            }
        }
    }
    
    func changeBoard(to indexPath: IndexPath) {
        guard let boardList = boardList else { return }
        resetPagingInstance()
        boardRelay.accept(boardList[indexPath.row])
    }
    
    private func resetPagingInstance() {
        currentOffset = 0
        isFetchable = nil
        hasNextPage = nil
    }
    
    func fetchPostList(for board: Board) {
        Task {
            let postList = await noticeBoardAPIFetcher.fetchPostList(boardID: board.boardId, offset: currentOffset, limit: 30)
            
            postRelay.accept(postList)
        }
    }
    
    func fetchNextPostList() {
        guard let hasNextPage = hasNextPage,
              let isFetchable = isFetchable else { return }
        
        if isFetchable == true, hasNextPage == true {
            
            self.isFetchable = false
            currentOffset += 30
            
            Task {
                guard let board = boardRelay.value,
                      let postList = postRelay.value else { return }

                let fetchedPostList = await noticeBoardAPIFetcher.fetchPostList(boardID: board.boardId, offset: currentOffset, limit: 30)
                let post = postList + fetchedPostList
                postRelay.accept(post)
            }
        }
        
    }

    func postListDidUpdated(with postList: [Post]) {
        hasNextPage = postList.count == 30
        isFetchable = true
    }
}
