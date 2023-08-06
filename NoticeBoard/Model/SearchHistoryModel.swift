//
//  SearchHistory.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/05.
//

import Foundation

struct SearchHistoryModel {
    
    let searchRecord: SearchRecordModel
    let createdDateTime: Date
}

struct SearchRecordModel: Equatable {
    
    let searchTarget: SearchTarget
    let keyword: String
}

extension SearchHistoryModel: Hashable, Equatable {
    
    static func == (lhs: SearchHistoryModel, rhs: SearchHistoryModel) -> Bool {
        return lhs.searchRecord == rhs.searchRecord && lhs.createdDateTime == rhs.createdDateTime
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(createdDateTime)
    }
}
