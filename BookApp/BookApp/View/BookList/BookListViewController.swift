import UIKit
import SnapKit
import RxSwift
import RxCocoa

// MARK: - 담은 책 리스트 화면
final class BookListViewController: UIViewController {
    
    private let bookListViewModel = BookListViewModel()
    private let disposeBag = DisposeBag()
    
    // Rx Subjects
    private let viewWillAppearSubject = PublishSubject<Void>()
    private let deleteAllButtonTapSubject = PublishSubject<Void>()
    private let addBookSubject = PublishSubject<BookDocument>()
    
    // 책 목록 데이터
    private var books: [BookDocument] = []
    
    private lazy var deleteAllButton: UIButton = {
        let delete = UIButton()
        delete.setTitle("전체 삭제", for: .normal)
        delete.setTitleColor(.black, for: .normal)
        delete.addTarget(self, action: #selector(deleteAllButtonClicked), for: .touchUpInside)  // 수정: addTarget 추가
        return delete
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "담은 책"
        title.font = .boldSystemFont(ofSize: 24)
        title.textColor = .black
        return title
    }()
    
    private lazy var addButton: UIButton = {
        let add = UIButton()
        add.setTitle("추가", for: .normal)
        add.setTitleColor(.black, for: .normal)
        add.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        return add
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            BookListCompositionalLayout.bookListLayout()
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    @objc private func deleteAllButtonClicked() {
        deleteAllButtonTapSubject.onNext(())
        print("delete all button click")
    }
    
    @objc private func addButtonClicked() {
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToSearchBar"), object: nil)
        print("add button click")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        viewHierarchy()
        viewLayout()
        setupCollectionView()
    }
    
    private func viewHierarchy() {
        [deleteAllButton, titleLabel, addButton, collectionView].forEach { view.addSubview($0) }
    }
    
    private func viewLayout() {
        deleteAllButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(12)
            make.width.equalTo(80)
            make.height.equalTo(55)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
            make.height.equalTo(55)
        }
        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.trailing.equalToSuperview().inset(12)
            make.width.equalTo(80)
            make.height.equalTo(55)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bindViewModel() {
        // Input 바인딩
        let input = BookListViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            deleteAllButtonTap: deleteAllButtonTapSubject.asObservable(),
            addBook: addBookSubject.asObservable()
        )
        
        // Output 바인딩
        let output = bookListViewModel.transform(with: input)
        
        output.books
            .drive(onNext: { [weak self] books in
                self?.books = books
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.deleteAllResult
            .drive(onNext: { success in
                if success {
                    print("모든 책이 삭제되었습니다.")
                } else {
                    print("책 삭제에 실패했습니다.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BookListCell.self, forCellWithReuseIdentifier: BookListCell.id)
    }
}

extension BookListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookListCell.id,
            for: indexPath
        ) as? BookListCell else {
            fatalError("BookListCell Fail")
        }
        let book = books[indexPath.item]
        cell.configure(with: book)
        return cell
    }
}

extension BookListViewController: DetailViewControllerDelegate {
    func detailViewController(_ viewController: DetailViewController, didAddBook book: BookDocument) {
        addBookSubject.onNext(book)
    }
}
