import UIKit
import SnapKit

final class MainSectionHeaderView: UICollectionReusableView {
    static let id = "MainSectionHeaderView"
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.font = .boldSystemFont(ofSize: 24)
        title.textColor = .black
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    private func setupHeader() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
