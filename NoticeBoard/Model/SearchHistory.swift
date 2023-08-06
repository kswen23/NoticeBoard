//
//  SearchHistory.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/05.
//

import Foundation

struct SearchHistory {
    
    let searchRecord: SearchRecord
    let createdDateTime: Date
}

struct SearchRecord: Equatable {
    
    let searchTarget: SearchTarget
    let keyword: String
}

extension SearchHistory: Hashable, Equatable {
    
    static func == (lhs: SearchHistory, rhs: SearchHistory) -> Bool {
        return lhs.searchRecord == rhs.searchRecord && lhs.createdDateTime == rhs.createdDateTime
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(createdDateTime)
    }
}
