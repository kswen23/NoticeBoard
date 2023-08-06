//
//  BoardListResponse.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/03.
//

import Foundation

struct BoardListResponse: Codable, Equatable {
    let value: [Board]
    let count: Int
    let offset: Int
    let limit: Int
    let total: Int
}

struct Board: Codable, Equatable {
    
    let boardId: Int
    let displayName: String
    let boardType: String
    let isFavorite: Bool
    let hasNewPost: Bool
    let orderNo: Int
    let capability: Capability
}

struct Capability: Codable, Equatable {
    
    let writable: Bool
    let manageable: Bool
}
