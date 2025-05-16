import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(_ viewController: DetailViewController, didAddBook book: BookDocument)
}

final class DetailViewController: UIViewController {

    weak var delegate: DetailViewControllerDelegate?
    
    private let detailViewModel = DetailViewModel()
    private var disposeBag = DisposeBag()
    
    // Rx Subjects
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let addButtonTapSubject = PublishSubject<Void>()
    private let cancelButtonTapSubject = PublishSubject<Void>()
    
    // UI Components
    private let titleLabel: UILabel = {
        let title  = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .medium)
        title.numberOfLines = 1
        title.textAlignment = .left
        title.lineBreakMode = .byTruncatingTail
        title.textColor = .label
        return title
    }()
    
    private let authorLabel: UILabel = {
        let author  = UILabel()
        author.font = .boldSystemFont(ofSize: 12)
        author.textColor = .lightGray
        author.textAlignment = .center
        return author
    }()
    
    private let bookImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    private let priceLabel: UILabel = {
        let price = UILabel()
        price.font = .systemFont(ofSize: 18)
        price.textAlignment = .center
        price.textColor = .black
        return price
    }()
    
    private let plotLabel: UILabel = {
        let plot = UILabel()
        plot.font = .systemFont(ofSize: 12, weight: .medium)
        plot.numberOfLines = 0
        plot.textAlignment = .left
        plot.textColor = .label
        return plot
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancel = UIButton()
        cancel.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancel.tintColor = .white
        cancel.backgroundColor = .lightGray
        return cancel
    }()
    
    private lazy var addButton: UIButton = {
        let add = UIButton()
        add.setTitle("담기", for: .normal)
        add.tintColor = .white
        add.backgroundColor = .green
        return add
    }()
    
    // MARK: - 초기화
    init(book: BookDocument) {
        super.init(nibName: nil, bundle: nil)
        detailViewModel.setBook(book)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        viewDidLoadSubject.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = DisposeBag()
    }

    // MARK: - UI 설정
    private func setupUI() {
        view.backgroundColor = .white
        viewHierarchy()
        viewLayout()
    }
    
    private func viewHierarchy() {
        [titleLabel, authorLabel,
         bookImage, priceLabel,
         plotLabel, cancelButton, addButton].forEach { view.addSubview($0) }
    }
    
    private func viewLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.centerX.equalToSuperview()
        }
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        bookImage.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(300)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(bookImage.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        plotLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(12)
            make.size.equalTo(80)
        }
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(cancelButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.height.equalTo(80)
        }
    }
    
    // MARK: - ViewModel 바인딩
    private func bindViewModel() {
        // Input 바인딩
        let input = DetailViewModel.Input(
            viewDidLoad: viewDidLoadSubject,
            addButtonTap: addButtonTapSubject,
            cancelButtonTap: cancelButtonTapSubject
        )
        
        // 버튼 액션 바인딩
        cancelButton.rx.tap
            .bind(to: cancelButtonTapSubject)
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .bind(to: addButtonTapSubject)
            .disposed(by: disposeBag)
        
        // Output 바인딩
        let output = detailViewModel.transform(with: input)
        
        output.titleText
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.authorText
            .drive(authorLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.priceText
            .drive(priceLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.plotText
            .drive(plotLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.imageURL
            .drive(onNext: { [weak self] url in
                if let url = url {
                    self?.bookImage.kf.setImage(with: url, placeholder: UIImage(systemName: "book"))
                } else {
                    self?.bookImage.image = UIImage(systemName: "book")
                }
            })
            .disposed(by: disposeBag)
        
        output.saveResult
            .drive(onNext: { [weak self] success in
                guard let self = self, success, let book = self.detailViewModel.getBook() else { return }
                self.delegate?.detailViewController(self, didAddBook: book)
            })
            .disposed(by: disposeBag)
        
        output.dismiss
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
