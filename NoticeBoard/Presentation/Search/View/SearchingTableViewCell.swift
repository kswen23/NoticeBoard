//
//  SearchingTableViewCell.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/06.
//

import Foundation
import UIKit

protocol SearchingTableViewCellDelegate: NSObject {
    func searchButtonDidTapped(cell: SearchingTableViewCell)
    
}

final class SearchingTableViewCell: UITableViewCell {
    
    static let identifier = "SearchingTableViewCell"
    
    weak var delegate: SearchingTableViewCellDelegate?
    
    private let searchTargetLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let keywordLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(searchButtonDidClicked), for: .touchUpInside)
        return button
    }()
    
    @objc private func searchButtonDidClicked() {
        delegate?.searchButtonDidTapped(cell: self)
    }
    
    // MARK: - Initialize
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func layout() {
        layoutSearchTargetLabel()
        layoutKeywordLabel()
        layoutSearchButton()
    }
    
    private func layoutSearchTargetLabel() {
        contentView.addSubview(searchTargetLabel)
        searchTargetLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTargetLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            searchTargetLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func layoutKeywordLabel() {
        contentView.addSubview(keywordLabel)
        keywordLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keywordLabel.leadingAnchor.constraint(equalTo: searchTargetLabel.trailingAnchor),
            keywordLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func layoutSearchButton() {
        contentView.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            searchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            searchButton.heightAnchor.constraint(equalToConstant: 18),
            searchButton.widthAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - configure
    func configureSearchingTableViewCell(item: SearchTarget, keyword: String) {
        searchTargetLabel.text = item.title
        searchTargetLabel.sizeToFit()
        keywordLabel.text = keyword
    }
}
