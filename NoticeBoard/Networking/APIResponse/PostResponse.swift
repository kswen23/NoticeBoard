//
//  PostListResponse.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/03.
//

import Foundation

struct Writer: Codable, Equatable {
    let displayName: String
    let emailAddress: String
}

struct Post: Codable, Equatable {
    let postId: Int
    let title: String
    let boardId: Int
    let boardDisplayName: String
    let writer: Writer
    let contents: String
    let createdDateTime: String
    let viewCount: Int
    let postType: String
    let isNewPost: Bool
    let hasInlineImage: Bool
    let commentsCount: Int
    let attachmentsCount: Int
    let isAnonymous: Bool
    let isOwner: Bool
    let hasReply: Bool
}

struct PostListResponse: Codable, Equatable {
    let value: [Post]
    let count: Int
    let offset: Int
    let limit: Int
    let total: Int
}
