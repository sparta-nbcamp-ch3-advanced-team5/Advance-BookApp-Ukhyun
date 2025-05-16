import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {

    // MARK: - Properties
    private let mainViewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private let searchQuerySubject = PublishSubject<String>()
    private let searchCancelSubject = PublishSubject<Void>()

    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "검색어를 입력주세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        search.searchTextField.textColor = .black
        search.barStyle = .default
        search.showsCancelButton = true
        return search
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = MainViewCompositionalLayout.create()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        navigationController?.navigationBar.isHidden = true
        
        // NotificationCenter 옵저버 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToSearchBar),
            name: NSNotification.Name("SwitchToSearchBar"),
            object: nil
        )
    }
    
    // searchBar로 전환
    @objc private func switchToSearchBar() {
        self.tabBarController?.selectedIndex = 0
        self.searchBar.becomeFirstResponder()
    }

    private func bindViewModel() {
        let input = MainViewModel.Input(
            searchQuery: searchQuerySubject.asObservable(),
            searchCancelTrigger: searchCancelSubject.asObservable(),
            itemSelected: collectionView.rx.itemSelected.asObservable()
        )

        let output = mainViewModel.transform(with: input)

        // 검색 결과 업데이트
        output.searchResults
            .drive(onNext: { [weak self] _ in
                self?.collectionView.reloadSections(IndexSet(integer: Section.searchResult.rawValue))
            })
            .disposed(by: disposeBag)

        // 최근 본 책 업데이트
        output.recentBooks
            .drive(onNext: { [weak self] _ in
                self?.collectionView.reloadSections(IndexSet(integer: Section.recentBook.rawValue))
            })
            .disposed(by: disposeBag)

        // 상세 화면 전환
        output.selectedBook
            .drive(onNext: { [weak self] bookData in
                guard let self = self, let (book, _) = bookData else { return }
                let detailVC = DetailViewController(book: book)
                detailVC.modalPresentationStyle = .pageSheet
                if let tabBarController = self.tabBarController,
                   let navController = tabBarController.viewControllers?[1] as? UINavigationController,
                   let bookListVC = navController.viewControllers.first as? BookListViewController {
                    detailVC.delegate = bookListVC
                }
                self.present(detailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { error in
                print("검색 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // 검색 버튼 이벤트 처리
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .bind(to: searchQuerySubject)
            .disposed(by: disposeBag)
        
        // 취소 버튼 이벤트 처리
        searchBar.rx.cancelButtonClicked
            .do(onNext: { [weak self] in
                self?.searchBar.text = ""
                self?.searchBar.resignFirstResponder()
            })
            .bind(to: searchCancelSubject)
            .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .white
        viewHierarchy()
        viewLayout()
        setupCollectionView()
    }

    private func viewHierarchy() {
        [searchBar, collectionView].forEach { view.addSubview($0) }
    }

    private func viewLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(55)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .recentBook:
            return mainViewModel.recentBooksRelay.value.count
        case .searchResult:
            return mainViewModel.searchResultsRelay.value.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .recentBook:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecentBooksCell.id,
                for: indexPath
            ) as? RecentBooksCell else {
                fatalError("RecentBooksCell Fail")
            }
            let book = mainViewModel.recentBooksRelay.value[indexPath.item]
            cell.configure(with: book)
            return cell
        case .searchResult:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchResultsCell.id,
                for: indexPath
            ) as? SearchResultsCell else {
                fatalError("SearchResultsCell Fail")
            }
            let book = mainViewModel.searchResultsRelay.value[indexPath.item]
            cell.configure(with: book)
            return cell
        default:
            fatalError("ERROR")
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MainSectionHeaderView.id,
                for: indexPath
            ) as! MainSectionHeaderView
            switch Section(rawValue: indexPath.section) {
            case .recentBook:
                header.titleLabel.text = "최근 본 책"
            case .searchResult:
                header.titleLabel.text = "검색 결과"
            default:
                header.titleLabel.text = ""
            }
            return header
        }
        fatalError("ERROR")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        var selectedBook: BookDocument
        
        switch section {
        case .recentBook:
            selectedBook = mainViewModel.recentBooksRelay.value[indexPath.item]
        case .searchResult:
            selectedBook = mainViewModel.searchResultsRelay.value[indexPath.item]
        }
        
        let detailVC = DetailViewController(book: selectedBook)
        detailVC.modalPresentationStyle = .pageSheet
        
        if let tabBarController = self.tabBarController,
           let navController = tabBarController.viewControllers?[1] as? UINavigationController,
           let bookListVC = navController.viewControllers.first as? BookListViewController {
            detailVC.delegate = bookListVC
        }
        
        present(detailVC, animated: true)
    }

    private func setupCollectionView() {
        collectionView.register(RecentBooksCell.self, forCellWithReuseIdentifier: RecentBooksCell.id)
        collectionView.register(SearchResultsCell.self, forCellWithReuseIdentifier: SearchResultsCell.id)
        collectionView.register(
            MainSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MainSectionHeaderView.id
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
