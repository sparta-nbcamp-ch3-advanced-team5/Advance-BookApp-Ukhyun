import UIKit
import SnapKit

final class RecentBooksCell: UICollectionViewCell {
    static let id = "RecentBookCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .green
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
