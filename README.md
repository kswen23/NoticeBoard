# NoticeBoard
### 개발 환경

- 언어 : Swift
- Deployment Target iOS 14
- UI 구현: Code-based (프로그래밍 방식으로 UI 구현)
- 앱의 아키텍쳐: MVVM 패턴
- 데이터 저장: 코어 데이터 (Core Data)
- OpenSource Libarary

[![Alamofire badge](https://img.shields.io/badge/Powered%20by-Alamofire-red)](https://github.com/Alamofire/Alamofire)
[![Moya badge](https://img.shields.io/badge/Powered%20by-Moya-orange)](https://github.com/Moya/Moya)
[![RxSwift badge](https://img.shields.io/badge/Powered%20by-RxSwift-green)](https://github.com/ReactiveX/RxSwift)
[![RxRelay badge](https://img.shields.io/badge/Powered%20by-RxRelay-brightgreen)](https://github.com/ReactiveX/RxRelay)
[![RxCocoa badge](https://img.shields.io/badge/Powered%20by-RxCocoa-yellow)](https://github.com/ReactiveX/RxSwift)



## 메인화면
![main](https://github.com/kswen23/NoticeBoard/assets/89299245/8e25e89c-47c5-412f-941a-38cc9f3ab3e6)

`NoticeBoardViewModel`은 게시판과 게시물 목록을 관리하며, 네트워크를 통해 서버에서 게시물 데이터를 가져오는 역할을 담당합니다. 또한 페이징 처리를 통해 추가로 게시물을 가져올 수 있도록 합니다.



1. 게시판과 게시물 데이터 관리:
`NoticeBoardViewModel`은 현재 선택된 게시판과 해당 게시판에 연관된 게시물 목록을 관리합니다. `boardRelay`와 `postRelay` 속성은 각각 `BehaviorRelay`입니다.

```swift
let boardRelay: BehaviorRelay<Board?> = BehaviorRelay(value: nil)
let postRelay: BehaviorRelay<[Post]?> = BehaviorRelay(value: nil)
```

2. 뷰 로드 시 게시판 데이터 가져오기:
`NoticeBoardViewController`가 로드될 때 `NoticeBoardViewModel`의 `viewDidLoad()` 메서드가 호출됩니다. 이를 통해 서버로부터 게시판 목록을 가져오는 `fetchBoardList()` 메서드가 실행됩니다.

```swift
func viewDidLoad() {
    fetchBoardList()
}
```

3. 서버에서 게시판 목록 가져오기:
`fetchBoardList()` 메서드는 `await`와 `async`를 사용하여 서버로부터 게시판 목록을 가져옵니다.

```swift
func fetchBoardList() {
    Task {
        boardList = await noticeBoardAPIFetcher.fetchBoardList()
        
        // 가져온 게시판 목록을 boardRelay에 업데이트합니다.
        guard let boardList = boardList else { return }
            
        await MainActor.run { [boardList] in
            self.boardRelay.accept(boardList[0])
        }
    }
}
```

4. 게시판 변경 및 관련 게시물 가져오기:
사용자가 메뉴에서 다른 게시판을 선택하면 `changeBoard(to indexPath:)` 메서드가 호출되어 선택한 게시판을 업데이트하고, 페이징 상태를 초기화한 뒤, 선택한 게시판에 관련된 게시물을 가져오는 `fetchPostList(for board:)` 메서드가 실행됩니다.

```swift
func changeBoard(to indexPath: IndexPath) {
    guard let boardList = boardList else { return }
    resetPagingInstance()
    boardRelay.accept(boardList[indexPath.row])
}
```

5. 서버에서 게시물 목록 가져오기:
`fetchPostList(for board:)` 메서드는 `await`와 `async`를 사용하여 선택된 게시판에 연관된 게시물 목록을 서버로부터 가져옵니다.

```swift
func fetchPostList(for board: Board) {
    Task {
        let postList = await noticeBoardAPIFetcher.fetchPostList(boardID: board.boardId, offset: currentOffset, limit: 30)
        
        // 가져온 게시물 목록을 postRelay에 업데이트합니다.
        postRelay.accept(postList)
    }
}
```

6. 무한 스크롤을 위한 페이징 처리:
`fetchNextPostList()` 메서드는 무한 스크롤을 위한 페이징 처리를 담당합니다. 사용자가 테이블 뷰를 아래로 스크롤할 때 추가 게시물을 가져올 수 있도록 합니다.

```swift
func fetchNextPostList() {
    guard let hasNextPage = hasNextPage, let isFetchable = isFetchable else { return }
    
    if isFetchable && hasNextPage {
        isFetchable = false
        currentOffset += 30
        Task {
                // 다음 일괄 게시물을 가져옵니다.
                guard let board = boardRelay.value,
                      let postList = postRelay.value else { return }
                
                let fetchedPostList = await noticeBoardAPIFetcher.fetchPostList(boardID: board.boardId, offset: currentOffset, limit: 30)
                let post = postList + fetchedPostList
                postRelay.accept(post)
            }
    }
}
```

7. 페이징 상태 업데이트:
`postListDidUpdated(with postList:)` 메서드는 가져온 게시물의 개수를 기반으로 `hasNextPage`와 `isFetchable` 상태 변수를 업데이트합니다.

```swift
func postListDidUpdated(with postList: [Post]) {
    hasNextPage = postList.count == currentOffset + 30
    isFetchable = true
}
```

## 검색화면
![search](https://github.com/kswen23/NoticeBoard/assets/89299245/4bec91ec-db27-41cb-9934-8348c4a9907c)

`SearchViewController`에서 검색 기능과 관련된 테이블 뷰 데이터 소스를 설정하고, 셀들을 구성합니다. 각 셀 클래스에서는 각 셀의 모양과 동작을 구현하고, 필요한 경우 델리게이트 패턴을 이용하여 `SearchViewController`로 이벤트를 전달합니다.

`SearchViewModel`은 검색어와 검색 결과를 관리하는 역할을 수행합니다. 이를 통해 최근 검색어를 표시하고, 검색어 입력에 따라 검색 테이블 뷰 셀을 생성하며, 검색 결과를 보여줍니다. 검색 결과 중에서 겹친 검색어를 강조하여 표시하는 기능도 포함됩니다.

1. 최근 검색어를 표시하는 기능:

`SearchViewModel`에서 `searchHistoryRelay`를 사용하여 최근 검색어를 관리하고, `SearchViewController`에서 `searchTableViewDataSource`를 이용하여 테이블 뷰에 표시합니다. 최근 검색어를 표시하는 셀은 `SearchHistoryTableViewCell` 클래스로 구현됩니다.

```swift
// SearchViewController.swift

// 최근 검색어를 테이블 뷰에 표시하는 데이터 소스 생성
private func makeSearchHistoryTableViewDataSource() -> UITableViewDiffableDataSource<Int, SearchHistoryModel> {
    return UITableViewDiffableDataSource(tableView: searchTableView) { tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.identifier, for: indexPath) as? SearchHistoryTableViewCell else { return UITableViewCell() }
        cell.configureCell(item: item)
        cell.delegate = self // 사용자가 검색 기록 삭제 버튼을 탭할 때 처리를 위해 델리게이트로 설정
        return cell
    }
}

// SearchHistoryTableViewCell.swift

final class SearchHistoryTableViewCell: UITableViewCell {
    static let identifier = "SearchHistoryTableViewCell"

    weak var delegate: SearchHistoryTableViewCellDelegate?

    // 검색 기록 셀 설정
    func configureCell(item: SearchHistoryModel) {
        // UI에 item 정보를 반영
        // ...
    }

    @objc private func deleteButtonTapped(_ sender: Any) {
        delegate?.deleteButtonDidTapped(cell: self)
    }
}
```

2. 검색어를 입력했을 때 검색된 텍스트 필드를 감지해 검색 테이블 뷰 셀을 생성하는 부분:

`SearchViewModel`에서 `searchingRelay`를 사용하여 검색어를 관리하고, `SearchViewController`에서 `searchingDataSource`를 이용하여 테이블 뷰에 검색 결과를 표시합니다. 검색 결과를 표시하는 셀은 `SearchingTableViewCell` 클래스로 구현됩니다.

```swift
// SearchViewController.swift

// 검색어를 테이블 뷰에 표시하는 데이터 소스 생성
private func makeSearchingTableViewDataSource(_ keyword: String) -> UITableViewDiffableDataSource<Int, SearchTarget> {
    return UITableViewDiffableDataSource(tableView: searchTableView) { tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchingTableViewCell.identifier, for: indexPath) as? SearchingTableViewCell else { return UITableViewCell() }
        cell.delegate = self // 사용자가 검색 버튼을 탭할 때 처리를 위해 델리게이트로 설정
        cell.configureSearchingTableViewCell(item: item, keyword: keyword)
        return cell
    }
}

// SearchingTableViewCell.swift

protocol SearchingTableViewCellDelegate: AnyObject {
    func searchButtonDidTapped(cell: SearchingTableViewCell)
}

final class SearchingTableViewCell: UITableViewCell {
    static let identifier = "SearchingTableViewCell"

    weak var delegate: SearchingTableViewCellDelegate?

    // 검색 테이블 뷰 셀 설정
    func configureSearchingTableViewCell(item: SearchTarget, keyword: String) {
        // UI에 item 정보와 keyword를 반영
        // ...
    }

    @objc private func searchButtonTapped(_ sender: Any) {
        delegate?.searchButtonDidTapped(cell: self)
    }
}
```

3. 검색 결과를 찾아 보여주는 부분:

`SearchViewModel`에서 `searchResultRelay`를 사용하여 검색 결과를 관리하고, `SearchViewController`에서 `searchResultTableViewDataSource`를 이용하여 테이블 뷰에 검색 결과를 표시합니다. 검색 결과를 표시하는 셀은 `PostTableViewCell` 클래스로 구현됩니다.

```swift
// SearchViewController.swift

// 검색 결과를 테이블 뷰에 표시하는 데이터 소스 생성
private func makeSearchResultTableViewDataSource() -> UITableViewDiffableDataSource<Int, Post> {
    return UITableViewDiffableDataSource(tableView: searchTableView) { [weak self] tableView, indexPath, item in
        guard let strongSelf = self,
              let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        cell.configureCell(item: item)
        cell.changeDuplicatedTextColor(searchText: strongSelf.viewModel.searchText) // 겹친 검색어 강조
        return cell
    }
}

// PostTableViewCell.swift

final class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"

    // 게시물 셀 설정
    func configureCell(item: Post) {
        // UI에 item 정보를 반영
        // ...
    }

    // 겹친 검색어 강조 설정
    func changeDuplicatedTextColor(searchText: String) {
        // UI에서 게시물의 제목, 내용 등에서 검색어와 겹치는 부분을 강조
        // ...
    }
}
```


## RemoteDataRepository (API)
### NoticeBoardAPI

```swift
import Foundation
import Moya

enum NoticeBoardAPI {
    case boardList
    case postList(boardID: Int, offset: Int, limit: Int)
    case searchPost(boardID: Int, search: String, searchTarget: SearchTarget.RawValue, offset: Int, limit: Int)
}

enum SearchTarget: String, CaseIterable {
    case all = "all"
    case title = "title"
    case contents = "contents"
    case writer = "writer"
}

extension NoticeBoardAPI: TargetType {
    var baseURL: URL {
        // 서버의 기본 URL
        return URL(string: "https://mp-dev.mail-server.kr/api/v2")!
    }

    var path: String {
        // 각 케이스에 따라 API 엔드포인트의 경로를 설정
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
        // 각 케이스에 따라 HTTP 메서드를 설정
        switch self {
        case .boardList, .postList, .searchPost:
            return .get
        }
    }

    var task: Moya.Task {
        // 각 케이스에 따라 API 요청에 필요한 매개변수들을 설정
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
        // API 요청에 필요한 헤더를 설정
        return [
            "Authorization": "Bearer <Your_Access_Token>"
        ]
    }
}

```

`NoticeBoardAPI`는 Moya 라이브러리에서 사용되는 열거형입니다. 서버 API와의 통신에 필요한 정보들을 정의하고 있습니다. 다음은 `NoticeBoardAPI` 열거형의 케이스들입니다:

1. `.boardList`: 게시판 목록을 가져오기 위한 API 요청입니다.
2. `.postList(boardID:offset:limit)`: 특정 게시판의 게시물 목록을 가져오기 위한 API 요청입니다.
3. `.searchPost(boardID:search:searchTarget:offset:limit)`: 특정 검색어와 검색 대상에 해당하는 게시물 목록을 가져오기 위한 API 요청입니다.


`SearchTarget` 열거형은 `NoticeBoardAPI`에서 사용되는 검색 대상에 대한 정보를 제공합니다. 이 열거형은 다음과 같은 케이스를 가지고 있으며, 각 케이스는 해당하는 검색 대상을 나타냅니다:

- `.all`: 전체 검색 대상
- `.title`: 제목 검색 대상
- `.contents`: 내용 검색 대상
- `.writer`: 작성자 검색 대상


위의 `extention` 코드는 `NoticeBoardAPI` 열거형을 Moya 라이브러리의 `TargetType` 프로토콜에 적용시킨 것입니다. `TargetType` 프로토콜의 구현을 통해 API 요청의 기본 정보를 설정합니다. `baseURL`, `path`, `method`, `task`, `headers` 등의 프로퍼티를 구현하여 각 케이스에 따른 API 요청의 설정을 정의합니다. 여기서 실제 값은 보안 상의 이유로 `<Your_Access_Token>` 등으로 대체되어 있습니다.


### NoticeBoardAPIFetcher

```swift
import Foundation
import Moya

protocol NoticeBoardAPIFetcherProtocol {
    func fetchBoardList() async -> [Board]
    func fetchPostList(boardID: Int, offset: Int, limit: Int) async -> [Post]
    func fetchSearchPostList(search: String, searchTarget: SearchTarget, boardID: Int, offset: Int, limit: Int) async -> [Post]
}

final class NoticeBoardAPIFetcher: NoticeBoardAPIFetcherProtocol {
    
    private let provider = MoyaProvider<NoticeBoardAPI>()
    
    func fetchBoardList() async -> [Board] {
        return await withCheckedContinuation { continuation in
            provider.request(.boardList) { result in
                switch result {
                    
                case .success(let response):
                    guard let data = try? response.map(BoardListResponse.self) else { return }
                    continuation.resume(returning: data.value)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchPostList(boardID: Int, offset: Int, limit: Int) async -> [Post] {
        return await withCheckedContinuation { continuation in
            provider.request(.postList(boardID: boardID, offset: offset, limit: limit)) { result in
                switch result {
                    
                case .success(let response):
                    guard let data = try? response.map(PostListResponse.self) else { return }
                    
                    let result = data.value.sorted { (post1, post2) -> Bool in
                        if post1.postType == "notice" && post2.postType != "notice" {
                            return true
                        } else if post1.postType != "notice" && post2.postType == "notice" {
                            return false
                        } else {
                            let date1 = Date.createdDateTimeToDate(post1.createdDateTime)
                            let date2 = Date.createdDateTimeToDate(post2.createdDateTime)
                            return date1 > date2
                        }
                    }
                    
                    continuation.resume(returning: result)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchSearchPostList(search: String, searchTarget: SearchTarget, boardID: Int, offset: Int, limit: Int) async -> [Post] {
        return await withCheckedContinuation { continuation in
            provider.request(.searchPost(boardID: boardID, search: search, searchTarget: searchTarget.rawValue, offset: offset, limit: limit)) { result in
                switch result {
                    
                case .success(let response):
                    guard let data = try? response.map(PostListResponse.self) else { return }
                    
                    let result = data.value.sorted { (post1, post2) -> Bool in
                        if post1.postType == "notice" && post2.postType != "notice" {
                            return true
                        } else if post1.postType != "notice" && post2.postType == "notice" {
                            return false
                        } else {
                            let date1 = Date.createdDateTimeToDate(post1.createdDateTime)
                            let date2 = Date.createdDateTimeToDate(post2.createdDateTime)
                            return date1 > date2
                        }
                    }
                    
                    continuation.resume(returning: result)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
```

`NoticeBoardAPIFetcher`는 `NoticeBoardAPI`와 통신하여 서버에서 데이터를 가져오는 역할을 수행하는 클래스입니다. Moya를 사용하여 `NoticeBoardAPI`와 통신하고, 비동기 작업을 처리합니다. 


1. `func fetchBoardList() async -> [Board]`: 게시판 목록을 가져오는 API 요청을 비동기적으로 수행합니다.

2. `func fetchPostList(boardID: Int, offset: Int, limit: Int) async -> [Post]`: 특정 게시판의 게시물 목록을 가져오는 API 요청을 비동기적으로 수행합니다.

3. `func fetchSearchPostList(search: String, searchTarget: SearchTarget, boardID: Int, offset: Int, limit: Int) async -> [Post]`: 특정 검색어와 검색 대상에 해당하는 게시물 목록을 가져오는 API 요청을 비동기적으로 수행합니다.

위 메서드들은 `withCheckedContinuation`를 사용하여 비동기 작업을 처리하고, API 요청 결과를 적절한 데이터 모델로 매핑하여 반환합니다. API 요청이 실패할 경우 에러를 처리하고 에러 로그를 출력합니다.

## LocalDataRepository (CoreData)
### CoreDataRepository

`CoreDataRepository`는 CoreData를 사용하여 검색 기록을 저장, 조회, 삭제하는 역할을 수행하는 클래스입니다. `CoreDataRepositoryProtocol` 프로토콜을 채택하여 저장(`saveSearchHistory(searchHistoryModel:)`), 조회(`fetchSearchHistory()`), 삭제(`deleteSearchHistory(searchHistoryModel:)`) 기능을 정의합니다.

1. #### `saveSearchHistory(searchHistoryModel:)` - 저장


```swift
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
```


- 먼저, 검색 기록이 이미 저장되어 있는지 확인하기 위해 `fetchRequest`를 생성합니다.
- 이때, `NSPredicate`를 사용하여 해당 검색 기록이 이미 존재하는지 확인합니다. 만약 이미 존재하는 경우에는 해당 검색 기록의 `createdDate`를 업데이트하고, 존재하지 않는 경우에는 새로운 검색 기록(`SearchHistory`)을 생성하여 `context`에 저장합니다.

이렇게 메서드는 CoreData의 컨텍스트를 이용하여 검색 기록을 저장하고, 이미 저장된 경우에는 기존 기록을 업데이트하는 방식으로 동작합니다. 이렇게 함으로써 검색 기록은 최신순으로 정렬되어 저장되며, 중복된 검색 기록을 방지할 수 있습니다.

2. #### `fetchSearchHistory()` - 불러오기

```swift
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
```


- CoreData에서 모든 검색 기록(`SearchHistory`)을 조회하고, 조회된 결과를 바탕으로 `SearchHistoryModel` 객체를 생성하여 배열에 추가합니다.
- 조회된 검색 기록들은 `createdDateTime`을 기준으로 내림차순으로 정렬되어 반환됩니다.

3. #### `deleteSearchHistory(searchHistoryModel:)` - 삭제

```swift
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

```


- `NSPredicate`를 사용하여 삭제할 검색 기록을 조회하고, 조회된 결과를 바탕으로 해당 검색 기록을 `context`에서 삭제합니다.
