import UIKit
import SnapKit

final class SearchResultsCell: UICollectionViewCell {
    static let id = "SearchResultsCell"
    
    // 컨테이너 뷰 추가
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()

    // 스택뷰 추가
    private lazy var bookInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    private let bookTitleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .medium)
        title.numberOfLines = 1
        title.textAlignment = .left
        title.lineBreakMode = .byTruncatingTail
        title.textColor = .label
        return title
    }()

    private let authorLabel: UILabel = {
        let author = UILabel()
        author.font = .systemFont(ofSize: 14, weight: .regular)
        author.numberOfLines = 0
        author.textColor = .secondaryLabel
        author.textAlignment = .center
        return author
    }()

    private let priceLabel: UILabel = {
        let price = UILabel()
        price.font = .systemFont(ofSize: 17, weight: .medium)
        price.numberOfLines = 0
        price.textAlignment = .right
        price.textColor = .label
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
        contentView.addSubview(containerView)
        containerView.addSubview(bookInfoStackView)
        [bookTitleLabel, authorLabel, priceLabel].forEach {
            bookInfoStackView.addArrangedSubview($0)
        }
    }

    private func viewLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bookInfoStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        bookTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }

        authorLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.25)
        }

        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.25)
        }
    }

    func configure(with book: BookDocument) {
        bookTitleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        priceLabel.text = "\(book.price.numberFormatted)원"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
