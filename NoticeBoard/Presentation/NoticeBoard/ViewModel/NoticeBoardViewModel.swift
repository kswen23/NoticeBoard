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
}

final class NoticeBoardViewModel: NoticeBoardViewModelProtocol {
    
    var boardList: [Board]?
    
    let boardRelay: BehaviorRelay<Board?> = .init(value: nil)
    let postRelay: BehaviorRelay<[Post]?> = .init(value: nil)
    
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
        boardRelay.accept(boardList[indexPath.row])
    }
    
    func fetchPostList(for board: Board) {
        Task {
            let postList = await noticeBoardAPIFetcher.fetchPostList(boardID: board.boardId, offset: 0, limit: 30)
            
            postRelay.accept(postList)
        }
    }

}
