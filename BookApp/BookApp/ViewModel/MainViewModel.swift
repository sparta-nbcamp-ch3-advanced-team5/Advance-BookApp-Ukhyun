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
    
    // 데이터 스트림
    private let searchResultsRelay = BehaviorRelay<[BookDocument]>(value: [])
    private let recentBooksRelay = BehaviorRelay<[BookDocument]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<Error>()
    
    // MARK: - Input & Output
    struct Input {
        let searchQuery: Observable<String>
        let searchCancelTrigger: Observable<Void>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let searchResults: Driver<[BookDocument]>
        let recentBooks: Driver<[BookDocument]>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
        let selectedBook: Driver<(BookDocument, IndexPath)?>
    }
    
    // MARK: - Transform
    func transform(with input: Input) -> Output {
        // 검색 쿼리 처리
        input.searchQuery
            .filter { !$0.isEmpty }
            .do(onNext: { [weak self] _ in
                self?.isLoadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] query -> Observable<[BookDocument]> in
                guard let self = self else { return .empty() }
                
                return self.fetchBooks(query: query)
                    .catch { error in
                        self.errorRelay.accept(error)
                        return .just([])
                    }
            }
            .do(onNext: { [weak self] books in
                self?.isLoadingRelay.accept(false)
                if let firstBook = books.first {
                    self?.addRecentBook(firstBook)
                }
            })
            .bind(to: searchResultsRelay)
            .disposed(by: disposeBag)
        
        // 검색 취소 처리
        input.searchCancelTrigger
            .subscribe(onNext: { [weak self] in
                self?.searchResultsRelay.accept([])
            })
            .disposed(by: disposeBag)
        
        // 아이템 선택 처리
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
            isLoading: isLoadingRelay.asDriver(),
            error: errorRelay.asDriver(onErrorJustReturn: NSError(domain: "Unknown Error", code: -1)),
            selectedBook: selectedBookDriver
        )
    }
    
    private func fetchBooks(query: String) -> Observable<[BookDocument]> {
        return Observable.create { observer in
            let api = KakaoBookAPI.search(query: query)
            
            let task = NetworkManager.shared.request(api: api) { (result: Result<BookSearchResponse, Error>) in
                switch result {
                case .success(let response):
                    observer.onNext(response.documents)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                // 취소 처리 (필요한 경우)
            }
        }
    }
    
    private func addRecentBook(_ book: BookDocument) {
        var currentBooks = recentBooksRelay.value
        if let existingIndex = currentBooks.firstIndex(where: { $0.title == book.title }) {
            currentBooks.remove(at: existingIndex)
        }
        currentBooks.insert(book, at: 0)
        recentBooksRelay.accept(currentBooks)
    }
}
