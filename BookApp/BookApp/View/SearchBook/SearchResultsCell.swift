import UIKit
import SnapKit

final class SearchResultsCell: UICollectionViewCell {
    static let id = "SearchResultsCell"
    
    private let bookTitleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 18)
        title.numberOfLines = 0
        title.textAlignment = .center
        return title
    }()
    
    private let authorLabel: UILabel = {
        let author = UILabel()
        author.font = .systemFont(ofSize: 12)
        author.numberOfLines = 0
        author.textColor = .lightGray
        author.textAlignment = .center
        return author
    }()
    
    private let priceLabel: UILabel = {
        let price = UILabel()
        price.font = .systemFont(ofSize: 14)
        price.numberOfLines = 0
        price.textAlignment = .center
        return price
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        viewHierarchy()
        viewLayout()
    }
    
    private func viewHierarchy() {
        [bookTitleLabel, authorLabel, priceLabel].forEach { contentView.addSubview($0) }
    }
    
    private func viewLayout() {
        bookTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
        }
        authorLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(bookTitleLabel.snp.trailing).offset(18)
        }
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
        }
    }
    
    func configure(with book: BookDocument) {
        bookTitleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        priceLabel.text = String(book.price)
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
