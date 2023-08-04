//
//  NoticeBoardAPIFetcher.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation

import Moya

protocol NoticeBoardAPIFetcherProtocol {
    
    func fetchBoardList() async -> [Board]
    func fetchPostList(boardID: Int,
                       offset: Int,
                       limit: Int) async -> [Post]
}

final class NoticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol {
    
    private let provider = MoyaProvider<NoticeBoardAPI>()
    
    func fetchBoardList() async -> [Board] {
        return await withCheckedContinuation { continuation in
            provider.request(.boardList) { result in
                switch result {
                    
                case .success(let response):
                    guard let data = try? response.map(BoardListResponse.self) else { return }
                    continuation.resume(returning: data.value)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchPostList(boardID: Int,
                       offset: Int,
                       limit: Int) async -> [Post] {
        return await withCheckedContinuation { continuation in
            provider.request(.postList(boardID: boardID,
                                       offset: offset,
                                       limit: limit)) { result in
                switch result {
                    
                case .success(let response):
                    guard let data = try? response.map(PostListResponse.self) else { return }
                    
                    let result = data.value.sorted { (post1, post2) -> Bool in
                        if post1.postType == "notice" && post2.postType != "notice" {
                            return true
                        } else if post1.postType != "notice" && post2.postType == "notice" {
                            return false
                        } else {
                            let date1 = Date.createdDateTimeToDate(post1.createdDateTime)
                            let date2 = Date.createdDateTimeToDate(post2.createdDateTime)
                            return date1 > date2
                        }
                    }
                    
                    continuation.resume(returning: result)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
