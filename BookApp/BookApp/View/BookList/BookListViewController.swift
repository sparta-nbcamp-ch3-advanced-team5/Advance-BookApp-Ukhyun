import UIKit
import SnapKit

// RxDataSource - Step

// MARK: - 담은 책 리스트 화면
final class BookListViewController: UIViewController {
    
    private lazy var deleteAllButton: UIButton = {
        let delete = UIButton()
        delete.setTitle("전체 삭제", for: .normal)
        delete.setTitleColor(.black, for: .normal)
        delete.addTarget(self, action: #selector(deleteAllButtonClciekd), for: .touchUpInside)
        return delete
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "담은 책"
        title.font = .boldSystemFont(ofSize: 24)
        title.textColor = .black
        return title
    }()
    
    private let addButton: UIButton = {
        let add = UIButton()
        add.setTitle("추가", for: .normal)
        add.setTitleColor(.black, for: .normal)
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
    
    private var bookList: [BookDocument] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        loadBooks()
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
    
    func configure(with book: [BookDocument]) {
        self.bookList.append(contentsOf: book)
        if isViewLoaded {
            collectionView.reloadData()
        }
    }

}
extension BookListViewController {
    @objc
    private func deleteAllButtonClciekd() {
        
    }
    
    // MARK: - CoreData
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
        self.bookList = bookDocuments
        collectionView.reloadData()
    }
}

extension BookListViewController: DetailViewControllerDelegate {
    func detailViewController(_ viewController: DetailViewController, didAddBook book: BookDocument) {
        loadBooks()
    }
}

extension BookListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookListCell.id,
            for: indexPath
        ) as? BookListCell else {
            fatalError("BookListCell Fail")
        }
        let book = bookList[indexPath.item]
        cell.configure(with: book)
        return cell
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(BookListCell.self, forCellWithReuseIdentifier: BookListCell.id)
    }
}
