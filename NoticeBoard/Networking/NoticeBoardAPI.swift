//
//  NoticeBoardAPI.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/03.
//

import Foundation

import Moya

enum NoticeBoardAPI {
    
    case boardList
    
    case postList(boardID: Int,
                  offset: Int,
                  limit: Int)
    
    case searchPost(boardID: Int,
                    search: String,
                    searchTarget: SearchTarget.RawValue,
                    offset: Int,
                    limit: Int)
    
    enum SearchTarget: String {
        
        case all = "all"
        case title = "title"
        case contents = "contents"
        case writer = "writer"
    }
    
}

extension NoticeBoardAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://mp-dev.mail-server.kr/api/v2")!
    }

    var path: String {
        switch self {
        case .boardList:
            return "/boards"
        case .postList(let boardID, _, _):
            return "/boards/\(boardID)/posts"
        case .searchPost(let boardID, _, _, _, _):
            return "/boards/\(boardID)/posts"
        }
    }

    var method: Moya.Method {
        switch self {
        case .boardList, .postList, .searchPost:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
            
        case .boardList:
            return .requestPlain
            
        case .postList(_, let offset, let limit):
            let parameters: [String: Any] = [
                "offset": offset,
                "limit": limit
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .searchPost(_, let search, let searchTarget, let offset, let limit):
            let parameters: [String: Any] = [
                "search": search,
                "searchTarget": searchTarget,
                "offset": offset,
                "limit": limit
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String : String]? {
        return [
            "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODgxMDM5NDAsImV4cCI6MCwidXNlcm5hbWUiOiJtYWlsdGVzdEBtcC1kZXYubXlwbHVnLmtyIiwiYXBpX2tleSI6IiMhQG1wLWRldiFAIyIsInNjb3BlIjpbImVhcyJdLCJqdGkiOiI5MmQwIn0.Vzj93Ak3OQxze_Zic-CRbnwik7ZWQnkK6c83No_M780"
        ]
    }
}
