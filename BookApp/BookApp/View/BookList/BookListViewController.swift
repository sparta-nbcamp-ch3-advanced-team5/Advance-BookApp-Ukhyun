import UIKit
import SnapKit

// MARK: - 담은 책 리스트 화면
final class BookListViewController: UIViewController {
    
    private let delelteAllButton: UIButton = {
        let delete = UIButton()
        delete.setTitle("전체 삭제", for: .normal)
        delete.setTitleColor(.black, for: .normal)
        delete.backgroundColor = .yellow
        return delete
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "담은 책"
        title.font = .boldSystemFont(ofSize: 24)
        title.textColor = .black
        title.backgroundColor = .yellow
        return title
    }()
    
    private let addButton: UIButton = {
        let add = UIButton()
        add.setTitle("추가", for: .normal)
        add.setTitleColor(.black, for: .normal)
        add.backgroundColor = .yellow
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
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        viewHierarchy()
        viewLayout()
        setupCollectionView()
    }
    
    private func viewHierarchy() {
        [delelteAllButton, titleLabel, addButton, collectionView].forEach { view.addSubview($0) }
    }
    
    private func viewLayout() {
        delelteAllButton.snp.makeConstraints { make in
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
extension BookListViewController: DetailViewControllerDelegate {
    func detailViewController(_ viewController: DetailViewController, didAddBook book: BookDocument) {
        self.bookList.append(book)
        collectionView.reloadData()
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
