//
//  MenuSelectViewModel.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation
import UIKit

protocol MenuSelectViewModelProtocol {
    
    var boardList: [Board] { get }
    
    func configureCell(cell: MenuSelectTableViewCell,
                       indexPath: IndexPath)
}

final class MenuSelectViewModel: MenuSelectViewModelProtocol {
    
    // MARK: - Initialize
    let boardList: [Board]
    
    init(boardList: [Board]) {
        self.boardList = boardList
    }
    
    func configureCell(cell: MenuSelectTableViewCell,
                       indexPath: IndexPath) {
        let title = boardList[indexPath.row].displayName
        cell.configureMenuSelectTableViewCell(title: title)
    }
}
