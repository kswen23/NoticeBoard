import UIKit

import RxSwift
import RxCocoa

enum SearchBarState {
    
    case searching
    case result
}

protocol CustomSearchBarDelegate: AnyObject {
    
    func searchBarDidBeginEditing(_ searchBar: CustomSearchNavigationBar)
    func searchBar(_ searchBar: CustomSearchNavigationBar, textDidChange searchText: String)
    func searchBarCancelButtonClicked(_ searchBar: CustomSearchNavigationBar)
}

class CustomSearchNavigationBar: UIView {
    
    var diposeBag = DisposeBag()
    
    weak var delegate: CustomSearchBarDelegate?
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        view.roundCorners(cornerRadius: 4)
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()
    
    private let magnifyingGlassImageView: UIView = {
        let imageBackgroundView = UIView()
        let imageView = UIImageView()
        imageView.image = .init(systemName: "magnifyingglass")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageBackgroundView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: imageBackgroundView.centerYAnchor),
            imageBackgroundView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        return imageBackgroundView
    }()
    
    private lazy var searchTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        searchTypeLabelWidthAnchor = label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width)
        searchTypeLabelWidthAnchor?.isActive = true
        label.isHidden = true
        return label
    }()
    
    private var searchTypeLabelWidthAnchor: NSLayoutConstraint?
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 24)
        ])
        return textField
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4
        
        [magnifyingGlassImageView, searchTypeLabel, textField].forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.tintColor = .darkGray
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 24),
        ])
        return button
    }()
    
    private lazy var cancelBackgroundView: UIView = {
        let view = UIView()
        view.addSubview(cancelButton)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 40),
            view.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    private lazy var backgroundStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundView.addSubview(searchStackView)
        NSLayoutConstraint.activate([
            searchStackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            searchStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 12),
            searchStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -12),
        ])
        
        [backgroundView, cancelBackgroundView].forEach{
            backgroundStackView.addArrangedSubview($0)
        }
        addSubview(backgroundStackView)
        NSLayoutConstraint.activate([
            backgroundStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            backgroundStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            backgroundStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        textField.delegate = self
        
        textField.rx.text
            .subscribe(onNext: { [weak self] changedText in
                guard let strongSelf = self,
                      let changedText = changedText else { return }
                self?.delegate?.searchBar(strongSelf, textDidChange: changedText)
            })
            .disposed(by: diposeBag)
        
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.searchBarCancelButtonClicked(self)
    }
    
    func configureTextFieldPlaceholder(placeholder: String) {
        textField.placeholder = placeholder
    }
    
    func resignTextField() {
        if textField.isEditing {
            textField.resignFirstResponder()
        }
    }
    
    func changeSearchBarState(text: String? = nil,
                              state: SearchBarState,
                              searchTarget: SearchTarget? = nil) {
        switch state {
        case .searching:
            searchTypeLabel.text = ""
            resizeSearchTypeLabelWidthAnchor()
            searchTypeLabel.isHidden = true
        case .result:
            guard let searchTypeTitle = searchTarget?.title,
                  let text = text else { return }
            textField.text = text
            searchTypeLabel.text = searchTypeTitle
            resizeSearchTypeLabelWidthAnchor()
            searchTypeLabel.isHidden = false
        }
    }
    
    private func resizeSearchTypeLabelWidthAnchor() {
        searchTypeLabelWidthAnchor?.isActive = false
        searchTypeLabelWidthAnchor = searchTypeLabel.widthAnchor.constraint(equalToConstant: searchTypeLabel.intrinsicContentSize.width)
        searchTypeLabelWidthAnchor?.isActive = true
    }
}
extension CustomSearchNavigationBar: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarDidBeginEditing(self)
    }
}
