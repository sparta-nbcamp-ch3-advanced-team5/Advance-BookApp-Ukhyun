import UIKit
import SnapKit

// MARK: - 책 검색 화면
final class MainViewController: UIViewController {
     
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
    
    private var searchResults: [BookDocument] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        searchBar.delegate = self
        navigationController?.navigationBar.isHidden = true
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
// MARK: - Network
extension MainViewController {
    private func fetchBooks(query: String) {
        let api = KakaoBookAPI.search(query: query)
        NetworkManager.shared.request(api: api) { [weak self] (result: Result<BookSearchResponse, Error>) in
            switch result {
            case .success(let response):
                self?.searchResults = response.documents
                DispatchQueue.main.async {
                    self?.collectionView.reloadSections(IndexSet(integer: Section.searchResult.rawValue))
                }
            case .failure(let error):
                print("검색 실패: \(error.localizedDescription)")
            }
        }
    }
    
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        fetchBooks(query: query)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResults = []
        collectionView.reloadSections(IndexSet(integer: Section.searchResult.rawValue))
        searchBar.resignFirstResponder()
    }
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .recentBook:
            return 5
        case .searchResult:
            return searchResults.count
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
            
            return cell
        case .searchResult:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchResultsCell.id,
                for: indexPath
            ) as? SearchResultsCell else {
                fatalError("SearchResultsCell Fail")
            }
            let book = searchResults[indexPath.item]
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
        guard Section(rawValue: indexPath.section) == .searchResult else { return }
        
        let detailVC = DetailViewController()
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
    private func setupCollectionView() {
        collectionView.register(RecentBooksCell.self, forCellWithReuseIdentifier: RecentBooksCell.id)
        collectionView.register(SearchResultsCell.self, forCellWithReuseIdentifier: SearchResultsCell.id)
        collectionView
            .register(
                MainSectionHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: MainSectionHeaderView.id
            )
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}
