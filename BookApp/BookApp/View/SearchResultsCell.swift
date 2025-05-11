import UIKit
import SnapKit

final class SearchResultsCell: UICollectionViewCell {
    static let id = "SearchResultsCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .brown
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
