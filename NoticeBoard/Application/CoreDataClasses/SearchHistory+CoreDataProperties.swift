//
//  SearchHistory+CoreDataProperties.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/06.
//
//

import Foundation
import CoreData


extension SearchHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistory> {
        return NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
    }

    @NSManaged public var searchTarget: String?
    @NSManaged public var keyword: String?
    @NSManaged public var createdDate: Date?

}

extension SearchHistory : Identifiable {

}
