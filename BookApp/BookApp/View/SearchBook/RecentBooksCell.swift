import UIKit
import SnapKit

final class RecentBooksCell: UICollectionViewCell {
    static let id = "RecentBookCell"
    
    private let bookTitleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 12)
        title.textAlignment = .center
        return title
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
        contentView.addSubview(bookTitleLabel)
    }
    
    private func viewLayout() {
        bookTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
