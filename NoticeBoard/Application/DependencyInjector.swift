//
//  DependencyInjector.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation
import UIKit

final class DependencyInjector {
    
    static let shared: DependencyInjector = DependencyInjector()
    
    private lazy var noticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol = NoticeBoardAPIFetcher()
    
    func makeNoticeBoardViewController() -> UIViewController {
        let viewModel: NoticeBoardViewModelProtocol = NoticeBoardViewModel(noticeBoardAPIFetcher: noticeBoardAPIFetcher)
        
        return NoticeBoardViewController(viewModel: viewModel)
    }
    
    func makeMenuSelectViewController(boardList: [Board],
                                      parentableViewController: MenuSelectViewControllerListener) -> UIViewController {
        let viewModel: MenuSelectViewModelProtocol = MenuSelectViewModel(boardList: boardList)
        let viewController: MenuSelectViewController = MenuSelectViewController(viewModel: viewModel)
        viewController.parentableViewController = parentableViewController
        return viewController
    }
    
    func makeSearchViewController(board: Board) -> SearchViewController {
        let viewModel: SearchViewModelProtocol = SearchViewModel(board: board,  noticeBoardAPIFetcher: noticeBoardAPIFetcher)
        
        return SearchViewController(viewModel: viewModel)
    }
}
