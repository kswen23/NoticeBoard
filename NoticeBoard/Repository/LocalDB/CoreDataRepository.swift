//
//  CoreDataRepository.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/06.
//

import CoreData
import Foundation
import UIKit

protocol CoreDataRepositoryProtocol {
    
    func saveSearchHistory(searchHistoryModel: SearchHistoryModel)
    func fetchSearchHistory() -> [SearchHistoryModel]
    func deleteSearchHistory(searchHistoryModel: SearchHistoryModel)
}

final class CoreDataRepository: CoreDataRepositoryProtocol {
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private lazy var context = appDelegate?.persistentContainer.viewContext
    
    func saveSearchHistory(searchHistoryModel: SearchHistoryModel) {
        guard let context = self.context else { return }
        
        let fetchRequest: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "searchTarget == %@ AND keyword == %@", searchHistoryModel.searchRecord.searchTarget.rawValue, searchHistoryModel.searchRecord.keyword)
        
        do {
            let existingRecords = try context.fetch(fetchRequest)
            
            if let existingRecord = existingRecords.first {
                existingRecord.createdDate = searchHistoryModel.createdDateTime
            } else {
                let newRecord = SearchHistory(context: context)
                newRecord.searchTarget = searchHistoryModel.searchRecord.searchTarget.rawValue
                newRecord.keyword = searchHistoryModel.searchRecord.keyword
                newRecord.createdDate = searchHistoryModel.createdDateTime
            }
            
            try context.save()
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    func fetchSearchHistory() -> [SearchHistoryModel] {
        guard let context = self.context else { return [] }
        
        let fetchRequest: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        
        do {
            let fetchedRecords = try context.fetch(fetchRequest)
            
            var searchHistoryModels: [SearchHistoryModel] = []
            
            for record in fetchedRecords {
                guard let searchTargetString = record.searchTarget,
                      let keywordString = record.keyword,
                      let date = record.createdDate else { continue }
                
                let searchTarget = SearchTarget(rawValue: searchTargetString)!
                let searchRecord = SearchRecordModel(searchTarget: searchTarget, keyword: keywordString)
                
                searchHistoryModels.append(SearchHistoryModel(searchRecord: searchRecord, createdDateTime: date))
                
            }
            
            searchHistoryModels.sort {
                $0.createdDateTime > $1.createdDateTime
            }
            
            return searchHistoryModels
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteSearchHistory(searchHistoryModel: SearchHistoryModel) {
        guard let context = self.context else { return }
        
        let fetchRequest: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        let predicate = NSPredicate(format: "searchTarget == %@ AND keyword == %@", searchHistoryModel.searchRecord.searchTarget.rawValue, searchHistoryModel.searchRecord.keyword)
        
        fetchRequest.predicate = predicate
        
        do {
            let fetchedRecords = try context.fetch(fetchRequest)
            
            for record in fetchedRecords {
                context.delete(record)
            }
            
            try context.save()
        } catch {
            print("Error deleting data: \(error.localizedDescription)")
        }
    }
    
}
