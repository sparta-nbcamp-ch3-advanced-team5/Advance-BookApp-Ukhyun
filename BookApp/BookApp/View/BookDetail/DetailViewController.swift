import UIKit
import SnapKit

final class DetailViewController: UIViewController {

    private let titleLabel: UILabel = {
        let title  = UILabel()
        title.font = .boldSystemFont(ofSize: 24)
        title.textAlignment = .center
        title.textColor = .black
        title.text = "@@@@@@@@@"
        return title
    }()
    
    private let authorLabel: UILabel = {
        let author  = UILabel()
        author.font = .boldSystemFont(ofSize: 12)
        author.textColor = .lightGray
        author.textAlignment = .center
        author.text = "@@@@@@@@"
        return author
    }()
    
    private let bookImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = UIImage(systemName: "house")
        return img
    }()
    
    private let priceLabel: UILabel = {
        let price = UILabel()
        price.font = .systemFont(ofSize: 18)
        price.textAlignment = .center
        price.textColor = .black
        price.text = "@@@@@@@"
        return price
    }()
    
    private let plotLabel: UILabel = {
        let plot = UILabel()
        plot.numberOfLines = 0
        plot.font = .systemFont(ofSize: 12)
        plot.textColor = .black
        plot.text = "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        return plot
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancel = UIButton()
        cancel.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancel.tintColor = .white
        cancel.backgroundColor = .lightGray
        cancel.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        return cancel
    }()
    
    private lazy var addButton: UIButton = {
        let add = UIButton()
        add.setTitle("담기", for: .normal)
        add.tintColor = .white
        add.backgroundColor = .green
        add.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        return add
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        viewHierarchy()
        viewLayout()
    }
    
    private func viewHierarchy() {
        [titleLabel, authorLabel,
         bookImage, priceLabel,
         plotLabel, cancelButton, addButton].forEach { view.addSubview($0) }
    }
    
    private func viewLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.centerX.equalToSuperview()
        }
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        bookImage.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(300)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(bookImage.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        plotLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
        }
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview().offset(12)
            make.size.equalTo(80)
        }
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(cancelButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.height.equalTo(80)
        }
    }
    
    @objc
    private func cancelButtonClicked() {
        dismiss(animated: true)
    }
    
    @objc
    private func addButtonClicked() {
        
    }
}
