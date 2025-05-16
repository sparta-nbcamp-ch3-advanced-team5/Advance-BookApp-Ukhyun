import Foundation
import RxSwift
import RxCocoa

protocol DetailViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output
    func transform(with: Input) -> Output
}

class DetailViewModel: DetailViewModelProtocol {
    
    private let disposeBag = DisposeBag()
    private var book: BookDocument?
    
    // 기본 생성자 추가
    init() {
        // 빈 초기화
    }
    
    // 기존 생성자 유지
    init(book: BookDocument) {
        self.book = book
    }
    
    // book을 설정하는 메서드 추가
    func setBook(_ book: BookDocument) {
        self.book = book
    }
    
    struct Input {
        let viewDidLoad: PublishSubject<Void>
        let addButtonTap: PublishSubject<Void>
        let cancelButtonTap: PublishSubject<Void>
    }

    struct Output {
        // 데이터 바인딩
        let titleText: Driver<String>
        let authorText: Driver<String>
        let imageURL: Driver<URL?>
        let priceText: Driver<String>
        let plotText: Driver<String>
        
        // 상태 관리
        let saveResult: Driver<Bool>
        let dismiss: Driver<Void>
    }
    
    func transform(with input: Input) -> Output {
        guard let book = self.book else {
            // book이 없는 경우 기본값 반환
            return createEmptyOutput(with: input)
        }
        
        // 데이터 바인딩을 위한 BehaviorRelay 생성
        let titleRelay = BehaviorRelay<String>(value: book.title)
        let authorRelay = BehaviorRelay<String>(value: book.authors.joined(separator: ", "))
        
        let url: URL?
        if let urlString = book.thumbnail, let imageURL = URL(string: urlString) {
            url = imageURL
        } else {
            url = nil
        }
        let imageURLRelay = BehaviorRelay<URL?>(value: url)
        
        let priceRelay = BehaviorRelay<String>(value: "\(book.price)원")
        let plotRelay = BehaviorRelay<String>(value: book.contents)
        
        // 책 저장 결과를 위한 PublishSubject
        let saveResultSubject = PublishSubject<Bool>()
        
        // 책 추가 버튼 탭 처리
        input.addButtonTap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let book = self.book else { return }
                
                if let saveBook = CoreDataManager.shared.saveBook(
                    title: book.title,
                    author: book.authors.joined(separator: ", "),
                    price: String(book.price)
                ) {
                    saveResultSubject.onNext(true)
                    print("ViewModel: 책 저장 성공")
                } else {
                    saveResultSubject.onNext(false)
                    print("ViewModel: 책 저장 실패")
                }
            })
            .disposed(by: disposeBag)
        
        // Output 구성 및 반환
        return Output(
            titleText: titleRelay.asDriver(),
            authorText: authorRelay.asDriver(),
            imageURL: imageURLRelay.asDriver(),
            priceText: priceRelay.asDriver(),
            plotText: plotRelay.asDriver(),
            saveResult: saveResultSubject.asDriver(onErrorJustReturn: false),
            dismiss: Observable.merge(input.cancelButtonTap, input.addButtonTap).asDriver(onErrorJustReturn: ())
        )
    }
    
    // book이 nil일 때 기본 Output 생성
    private func createEmptyOutput(with input: Input) -> Output {
        return Output(
            titleText: Driver.just(""),
            authorText: Driver.just(""),
            imageURL: Driver.just(nil),
            priceText: Driver.just(""),
            plotText: Driver.just(""),
            saveResult: Driver.just(false),
            dismiss: input.cancelButtonTap.asDriver(onErrorJustReturn: ())
        )
    }
    
    // 현재 설정된 book 객체 반환 (ViewController에서 사용 가능)
    func getBook() -> BookDocument? {
        return book
    }
}
