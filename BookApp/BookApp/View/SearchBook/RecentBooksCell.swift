import UIKit
import SnapKit

final class RecentBooksCell: UICollectionViewCell {
    static let id = "RecentBookCell"
    
    private let bookTitleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 17, weight: .medium)
        title.numberOfLines = 1
        title.textAlignment = .left
        title.lineBreakMode = .byTruncatingTail
        title.textColor = .label
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        viewHierarchy()
        viewLayout()
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 8
    }
    
    private func viewHierarchy() {
        contentView.addSubview(bookTitleLabel)
    }
    
    private func viewLayout() {
        bookTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
        }
    }
    
    func configure(with book: BookDocument) {
        bookTitleLabel.text = book.title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
