import Foundation
import RxSwift
import RxCocoa

protocol MainViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output
    func transform(with: Input) -> Output
}

class MainViewModel: MainViewModelProtocol {

    // MARK: - 프로퍼티
    private let disposeBag = DisposeBag()
    
    private(set) var searchResultsRelay = BehaviorRelay<[BookDocument]>(value: []) // 검색 결과
    private(set) var recentBooksRelay = BehaviorRelay<[BookDocument]>(value: []) // 최근 본 책
    private(set) var isLoadingRelay = BehaviorRelay<Bool>(value: false) // 로딩 상태
    private let errorRelay = PublishRelay<Error>() // 에러 전달

    private(set) var currentPage = 1
    private(set) var isLastPage = false
    private(set) var currentQuery = ""
    
    // MARK: - Input/Output 정의
    struct Input {
        let searchQuery: Observable<String>
        let searchCancelTrigger: Observable<Void>
        let itemSelected: Observable<IndexPath>
        let loadNextPageTrigger: Observable<Void>
    }

    struct Output {
        let searchResults: Driver<[BookDocument]>
        let recentBooks: Driver<[BookDocument]>
        let error: Driver<Error>
        let selectedBook: Driver<(BookDocument, IndexPath)?>
        let isLoading: Driver<Bool>
    }

    // MARK: - transform
    func transform(with input: Input) -> Output {

        // 검색어 입력 처리
        input.searchQuery
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .flatMapLatest { [weak self] query -> Observable<[BookDocument]> in
                guard let self = self else { return .empty() }
                return self.fetchBooks(query: query)
                    .catch { [weak self] error in
                        self?.errorRelay.accept(error)
                        return .just([])
                    }
            }
            .bind(to: searchResultsRelay)
            .disposed(by: disposeBag)

        // 검색 취소 처리
        input.searchCancelTrigger
            .subscribe(onNext: { [weak self] in
                self?.resetSearch()
            })
            .disposed(by: disposeBag)

        // 셀 선택 처리
        let combinedData = Observable.combineLatest(
            searchResultsRelay.asObservable(),
            recentBooksRelay.asObservable()
        )

        let selectedBookDriver = input.itemSelected
            .withLatestFrom(combinedData) { indexPath, data -> (BookDocument, IndexPath)? in
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

        // 페이징(다음 페이지) 처리
        input.loadNextPageTrigger
            .withLatestFrom(isLoadingRelay.asObservable())
            .filter { !$0 }
            .withLatestFrom(Observable.just(self)) // self를 캡처
            .filter { !$0.isLastPage && !$0.currentQuery.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?.fetchNextPage()
            })
            .disposed(by: disposeBag)

        return Output(
            searchResults: searchResultsRelay.asDriver(),
            recentBooks: recentBooksRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: NSError(domain: "Unknown Error", code: -1)),
            selectedBook: selectedBookDriver,
            isLoading: isLoadingRelay.asDriver()
        )
    }

    // MARK: - 네트워크 책 검색 (새 검색)
    private func fetchBooks(query: String) -> Observable<[BookDocument]> {
        // 새 검색 시 페이징 정보 초기화
        currentPage = 1
        isLastPage = false
        currentQuery = query
        isLoadingRelay.accept(true)

        let api = KakaoBookAPI.search(query: query, page: currentPage)
        return NetworkManager.shared.callRequest(api: api)
            .map { [weak self] (response: BookSearchResponse) -> [BookDocument] in
                self?.isLastPage = response.meta.is_end
                self?.isLoadingRelay.accept(false)
                return response.documents
            }
            .do(onError: { [weak self] _ in
                self?.isLoadingRelay.accept(false)
            })
    }

    // MARK: - 다음 페이지 로드
    private func fetchNextPage() {
        guard !isLoadingRelay.value && !isLastPage && !currentQuery.isEmpty else { return }
        isLoadingRelay.accept(true)
        currentPage += 1

        let api = KakaoBookAPI.search(query: currentQuery, page: currentPage)
        NetworkManager.shared.callRequest(api: api)
            .map { [weak self] (response: BookSearchResponse) -> [BookDocument] in
                self?.isLastPage = response.meta.is_end
                return response.documents
            }
            .subscribe(onNext: { [weak self] books in
                guard let self = self else { return }
                var currentBooks = self.searchResultsRelay.value
                currentBooks.append(contentsOf: books)
                self.searchResultsRelay.accept(currentBooks)
                self.isLoadingRelay.accept(false)
            }, onError: { [weak self] error in
                self?.errorRelay.accept(error)
                self?.isLoadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 검색 리셋
    private func resetSearch() {
        searchResultsRelay.accept([])
        currentQuery = ""
        currentPage = 1
        isLastPage = false
        isLoadingRelay.accept(false)
    }

    // MARK: - 최근 본 책 추가
    func addRecentBook(_ book: BookDocument) {
        var currentBooks = recentBooksRelay.value
        if let existingIndex = currentBooks.firstIndex(where: { $0.title == book.title }) {
            currentBooks.remove(at: existingIndex)
        }
        currentBooks.insert(book, at: 0)
        // 최근 10개만 유지
        if currentBooks.count > 10 {
            currentBooks = Array(currentBooks.prefix(10))
        }
        recentBooksRelay.accept(currentBooks)
    }
}
