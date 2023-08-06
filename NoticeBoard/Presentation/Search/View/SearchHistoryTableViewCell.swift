//
//  SearchHistoryTableViewCell.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/05.
//

import Foundation
import UIKit

protocol SearchHistoryTableViewCellDelegate: NSObject {
    func deleteButtonDidTapped(cell: SearchHistoryTableViewCell)
    
}

final class SearchHistoryTableViewCell: UITableViewCell {
    
    static let identifier = "SearchHistoryTableViewCell"
    
    weak var delegate: SearchHistoryTableViewCellDelegate?
    
    private let clockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock.arrow.circlepath")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .black
        return imageView
    }()
    
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
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(deleteButtonDidClicked), for: .touchUpInside)
        return button
    }()
    
    @objc private func deleteButtonDidClicked() {
        delegate?.deleteButtonDidTapped(cell: self)
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
        layoutClockImageView()
        layoutSearchTargetLabel()
        layoutKeywordLabel()
        layoutDeleteButton()
    }
    
    private func layoutClockImageView() {
        contentView.addSubview(clockImageView)
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clockImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            clockImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            clockImageView.heightAnchor.constraint(equalToConstant: 24),
            clockImageView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func layoutSearchTargetLabel() {
        contentView.addSubview(searchTargetLabel)
        searchTargetLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTargetLabel.leadingAnchor.constraint(equalTo: clockImageView.trailingAnchor, constant: 6),
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
    
    private func layoutDeleteButton() {
        contentView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 18),
            deleteButton.widthAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    // MARK: - configure
    func configureCell(item: SearchHistoryModel) {
        searchTargetLabel.text = item.searchRecord.searchTarget.title
        searchTargetLabel.sizeToFit()
        keywordLabel.text = item.searchRecord.keyword
    }
    
}
