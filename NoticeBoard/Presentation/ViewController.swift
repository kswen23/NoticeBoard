//
//  ViewController.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/01.
//

import UIKit

import Moya

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let provider = MoyaProvider<NoticeBoardAPI>()
        
        provider.request(.boardList) { result in
            switch result {
            case .success(let response):
                // 성공적으로 데이터를 받아온 경우 처리하는 로직
                guard let data = try? response.map(BoardListResponse.self) else { return }
                print(data)
                data.value.forEach { board in
                    provider.request(.postList(boardID: board.boardId, offset: 0, limit: 2)) { result in
                        switch result {
                        case .success(let response):
                            guard let data = try?response.map(PostListResponse.self) else { return }
                            print(data)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                
            case .failure(let error):
                // 요청 실패한 경우 처리하는 로직
                print("Error: \(error)")
            }
        }
    }
    
    
}

