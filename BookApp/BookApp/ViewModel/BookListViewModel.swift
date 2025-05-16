import Foundation
import RxSwift
import RxCocoa

protocol BookListViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output
    func transform(with: Input) -> Output
}

class BookListViewModel: BookListViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    
    // 책 목록을 위한 BehaviorRelay
    private let booksRelay = BehaviorRelay<[BookDocument]>(value: [])
    
    init() {
        loadBooks()
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let deleteAllButtonTap: Observable<Void>
        let addBook: Observable<BookDocument>
    }
    
    struct Output {
        let books: Driver<[BookDocument]>
        let deleteAllResult: Driver<Bool>
    }
    
    func transform(with input: Input) -> Output {
        // 화면이 나타날 때마다 책 목록 새로고침
        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                self?.loadBooks()
            })
            .disposed(by: disposeBag)
        
        // 전체 삭제 버튼 탭 처리
        let deleteResultSubject = PublishSubject<Bool>()
        
        input.deleteAllButtonTap
            .subscribe(onNext: { [weak self] _ in
                if CoreDataManager.shared.deleteAllBooks() {
                    self?.booksRelay.accept([])
                    deleteResultSubject.onNext(true)
                } else {
                    deleteResultSubject.onNext(false)
                }
            })
            .disposed(by: disposeBag)
        
        // 책 추가 이벤트 처리
        input.addBook
            .subscribe(onNext: { [weak self] _ in
                self?.loadBooks()
            })
            .disposed(by: disposeBag)
        
        return Output(
            books: booksRelay.asDriver(),
            deleteAllResult: deleteResultSubject.asDriver(onErrorJustReturn: false)
        )
    }
    
    // CoreData에서 책 목록 불러오기
    private func loadBooks() {
        let savedBooks = CoreDataManager.shared.fetchAllBooks()
        
        let bookDocuments = savedBooks.compactMap { entity -> BookDocument? in
            guard let title = entity.title,
                  let author = entity.author,
                  let priceString = entity.price,
                  let price = Int(priceString) else {
                return nil
            }
            return BookDocument(
                title: title,
                authors: [author],
                contents: "",
                thumbnail: nil,
                price: price
            )
        }
        booksRelay.accept(bookDocuments)
    }
}
