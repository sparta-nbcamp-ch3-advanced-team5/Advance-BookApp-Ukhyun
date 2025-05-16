import Foundation
import RxSwift
import RxCocoa

protocol MainViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output
    func transform(with: Input) -> Output
}

class MainViewModel: MainViewModelProtocol {

    private let disposeBag = DisposeBag()
    private(set) var searchResultsRelay = BehaviorRelay<[BookDocument]>(value: []) // 검색 결과
    private(set) var recentBooksRelay = BehaviorRelay<[BookDocument]>(value: []) // 최근 본 책
    private let errorRelay = PublishRelay<Error>() // 에러 전달

    struct Input {
        let searchQuery: Observable<String>
        let searchCancelTrigger: Observable<Void>
        let itemSelected: Observable<IndexPath>
    }

    struct Output {
        let searchResults: Driver<[BookDocument]>
        let recentBooks: Driver<[BookDocument]>
        let error: Driver<Error>
        let selectedBook: Driver<(BookDocument, IndexPath)?>
    }

    func transform(with input: Input) -> Output {
        // 검색어 입력 처리
        input.searchQuery
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] query -> Observable<[BookDocument]> in
                guard let self = self else { return .empty() }
                return self.fetchBooks(query: query)
                    .catch { error in
                        self.errorRelay.accept(error)
                        return .just([])
                    }
            }
            .bind(to: searchResultsRelay)
            .disposed(by: disposeBag)

        // 검색 취소 처리
        input.searchCancelTrigger
            .subscribe(onNext: { [weak self] in
                self?.searchResultsRelay.accept([])
            })
            .disposed(by: disposeBag)

        // 셀 선택 처리
        let selectedBookDriver = input.itemSelected
            .withLatestFrom(Observable.combineLatest(
                searchResultsRelay.asObservable(),
                recentBooksRelay.asObservable()
            )) { indexPath, data -> (BookDocument, IndexPath)? in
                let (searchResults, recentBooks) = data
                guard let section = Section(rawValue: indexPath.section) else { return nil }
                switch section {
                case .recentBook:
                    guard indexPath.item < recentBooks.count else { return nil }
                    return (recentBooks[indexPath.item], indexPath)
                case .searchResult:
                    guard indexPath.item < searchResults.count else { return nil }
                    return (searchResults[indexPath.item], indexPath)
                }
            }
            .asDriver(onErrorJustReturn: nil)

        return Output(
            searchResults: searchResultsRelay.asDriver(),
            recentBooks: recentBooksRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: NSError(domain: "Unknown Error", code: -1)),
            selectedBook: selectedBookDriver
        )
    }

    // 네트워크 책 검색
    private func fetchBooks(query: String) -> Observable<[BookDocument]> {
        let api = KakaoBookAPI.search(query: query)
        return NetworkManager.shared.callRequest(api: api)
            .map { (response: BookSearchResponse) in
                response.documents
            }
            .catch { [weak self] error in
                self?.errorRelay.accept(error)
                return .just([])
            }
    }

    // 최근 본 책 추가
    func addRecentBook(_ book: BookDocument) {
        var currentBooks = recentBooksRelay.value
        if let existingIndex = currentBooks.firstIndex(where: { $0.title == book.title }) {
            currentBooks.remove(at: existingIndex)
        }
        currentBooks.insert(book, at: 0)
        recentBooksRelay.accept(currentBooks)
    }
}
