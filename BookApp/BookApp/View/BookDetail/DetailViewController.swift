import UIKit
import SnapKit
import Kingfisher

protocol DetailViewControllerDelegate: AnyObject {
    func detailViewController(_ viewController: DetailViewController, didAddBook book: BookDocument)
}

final class DetailViewController: UIViewController {

    weak var delegate: DetailViewControllerDelegate?
    
    private var book: BookDocument?
    
    private let titleLabel: UILabel = {
        let title  = UILabel()
        title.font = .boldSystemFont(ofSize: 24)
        title.textAlignment = .center
        title.textColor = .black
        return title
    }()
    
    private let authorLabel: UILabel = {
        let author  = UILabel()
        author.font = .boldSystemFont(ofSize: 12)
        author.textColor = .lightGray
        author.textAlignment = .center
        return author
    }()
    
    private let bookImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    private let priceLabel: UILabel = {
        let price = UILabel()
        price.font = .systemFont(ofSize: 18)
        price.textAlignment = .center
        price.textColor = .black
        return price
    }()
    
    private let plotLabel: UILabel = {
        let plot = UILabel()
        plot.numberOfLines = 0
        plot.font = .systemFont(ofSize: 12)
        plot.textColor = .black
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
    
    func configure(with book: BookDocument) {
        self.book = book
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        priceLabel.text = "\(book.price)원"
        plotLabel.text = book.contents
        
        if let urlString = book.thumbnail, let url = URL(string: urlString) {
            bookImage.kf.setImage(with: url, placeholder: UIImage(systemName: "book"))
        } else {
            bookImage.image = UIImage(systemName: "book")
        }
    }
    
    @objc
    private func cancelButtonClicked() {
        dismiss(animated: true)
    }
    
    @objc
    private func addButtonClicked() {
        guard let book = self.book else { return }
        delegate?.detailViewController(self, didAddBook: book)
        dismiss(animated: true)
    }
}
