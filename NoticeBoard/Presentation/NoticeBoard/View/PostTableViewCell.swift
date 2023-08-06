//
//  PostTableViewCell.swift
//  NoticeBoard
//
//  Created by 김성원 on 2023/08/04.
//

import Foundation
import UIKit

final class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = topStackViewSpacing
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.translatesAutoresizingMaskIntoConstraints = false
        view.roundCorners(cornerRadius: topStackViewHeightConstant/2)
        let label = UILabel()
        label.text = "공지"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: noticeViewWidth),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.isHidden = true
        return view
    }()
    
    private lazy var replyView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.roundCorners(cornerRadius: topStackViewHeightConstant/2)
        let label = UILabel()
        label.text = "Re"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: replyViewWidth),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.isHidden = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var paperclipImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "paperclip")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: paperClipImageViewWidth)
        ])
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var isNewPostView: UIView = {
        let backgroundView = UIView()
        let newPostView = UIView()
        newPostView.backgroundColor = .systemRed
        newPostView.translatesAutoresizingMaskIntoConstraints = false
        newPostView.roundCorners(cornerRadius: 8)
        backgroundView.addSubview(newPostView)
        let label = UILabel()
        label.text = "N"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        newPostView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: newPostView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: newPostView.centerYAnchor),
            newPostView.widthAnchor.constraint(equalToConstant: isNewPostViewWidth),
            newPostView.heightAnchor.constraint(equalToConstant: 16),
            newPostView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
        
        backgroundView.isHidden = true
        return backgroundView
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let writerLabel: UILabel = UILabel()
    private let writtenTimeLabel: UILabel = UILabel()
    private lazy var viewCountLabel: UILabel = {
        let label = UILabel()
        label.font = bottomLabelFont
        label.textColor = bottomLabelTintColor
        return label
    }()
    private lazy var viewsStackView: UIStackView = {
        let eyeImage = UIImage(systemName: "eye")
        let eyeImageView = UIImageView(image: eyeImage)
        eyeImageView.tintColor = bottomLabelTintColor
        eyeImageView.translatesAutoresizingMaskIntoConstraints = false
        eyeImageView.widthAnchor.constraint(equalToConstant: bottomStackViewHeightConstant).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [eyeImageView, viewCountLabel])
        stackView.axis = .horizontal
        stackView.spacing = bottomStackViewSpacing
        return stackView
    }()
    
    private let stackViewPadding: CGFloat = 10
    private let topStackViewHeightConstant: CGFloat = 24
    private let topStackViewSpacing: CGFloat = 2
    private let noticeViewWidth: CGFloat = 39
    private lazy var replyViewWidth: CGFloat = 31
    private let paperClipImageViewWidth: CGFloat = 20
    private let isNewPostViewWidth: CGFloat = 20
    private var topStackViewWidthNSConstraint: NSLayoutConstraint?
    
    private let bottomStackViewHeightConstant: CGFloat = 18
    private let bottomStackViewSpacing: CGFloat = 1
    private let bottomLabelTintColor: UIColor = .systemGray
    private let bottomLabelFont: UIFont = .systemFont(ofSize: 12, weight: .light)
    private let writerLabelMaxWidth: CGFloat = 84
    private var writerLabelWidthNSConstraint: NSLayoutConstraint?
    
    // MARK: - Initialize
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareTopStackViewForReuse()
        writerLabelWidthNSConstraint?.isActive = false
    }
    
    private func prepareTopStackViewForReuse() {
        noticeView.isHidden = true
        replyView.isHidden = true
        paperclipImageView.isHidden = true
        isNewPostView.isHidden = true
        topStackViewWidthNSConstraint?.isActive = false
    }
    // MARK: - Layout
    private func layout() {
        layoutStackView()
    }
    
    private func layoutStackView() {
        layoutTopStackView()
        layoutBottomStackView()
    }
    
    private func layoutTopStackView() {
        contentView.addSubview(topStackView)
        [noticeView, replyView, titleLabel, paperclipImageView, isNewPostView].forEach {
            topStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            topStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: stackViewPadding),
            topStackView.heightAnchor.constraint(equalToConstant: topStackViewHeightConstant),
            topStackView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    private func layoutBottomStackView() {
        contentView.addSubview(bottomStackView)
        [writerLabel, writtenTimeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = bottomLabelTintColor
            $0.font = bottomLabelFont
            bottomStackView.addArrangedSubview($0)
        }
        
        bottomStackView.addArrangedSubview(viewsStackView)
        
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: stackViewPadding),
            bottomStackView.heightAnchor.constraint(equalToConstant: bottomStackViewHeightConstant),
            bottomStackView.topAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    // MARK: - Configure
    func configureCell(item: Post) {
        configureTopStackView(item: item)
        configureBottomStackView(item: item)
    }
    private func configureTopStackView(item: Post) {
        configurePostType(postType: item.postType)
        configureTitleLabel(title: item.title)
        paperclipImageView.isHidden = !item.hasInlineImage
        isNewPostView.isHidden = !item.isNewPost
        configureTopStackViewWidth(item: item)
    }
    
    private func configurePostType(postType: String) {
        if postType == "notice" {
            noticeView.isHidden = false
        } else if postType == "reply" {
            replyView.isHidden = false
        }
    }
    
    private func configureTitleLabel(title: String) {
        titleLabel.text = title
        titleLabel.sizeToFit()
    }
    
    private func configureTopStackViewWidth(item: Post) {
        let cellWidth = UIScreen.main.bounds.width
        let maxTopStackViewHeight = cellWidth - (stackViewPadding*4)
        
        var topStackViewEstimatedWidth: CGFloat = 0
        
        if item.postType == "notice" {
            topStackViewEstimatedWidth = topStackViewEstimatedWidth + noticeViewWidth + topStackViewSpacing
        } else if item.postType == "reply" {
            topStackViewEstimatedWidth = topStackViewEstimatedWidth + replyViewWidth + topStackViewSpacing
        }
        
        topStackViewEstimatedWidth = topStackViewEstimatedWidth + titleLabel.bounds.width + topStackViewSpacing
        
        if item.hasInlineImage {
            topStackViewEstimatedWidth = topStackViewEstimatedWidth + paperClipImageViewWidth + topStackViewSpacing
        }
        
        if item.isNewPost {
            topStackViewEstimatedWidth = topStackViewEstimatedWidth + isNewPostViewWidth + topStackViewSpacing
        }
        
        topStackViewEstimatedWidth = min(topStackViewEstimatedWidth, maxTopStackViewHeight)
        
        topStackViewWidthNSConstraint = topStackView.widthAnchor.constraint(equalToConstant: topStackViewEstimatedWidth)
        
        topStackViewWidthNSConstraint?.isActive = true
    }
    
    private func configureBottomStackView(item: Post) {
        configureWriterLabel(writer: item.writer.displayName)
        configureWrittenTimeLabel(writtenTime: item.createdDateTime)
        viewCountLabel.text = "\(item.viewCount)"
    }
    
    private func configureWriterLabel(writer: String) {
        writerLabel.text = writer
        writerLabel.sizeToFit()
        let estimatedWriterLabelWidth: CGFloat = min(writerLabel.bounds.width, writerLabelMaxWidth)
        writerLabelWidthNSConstraint = writerLabel.widthAnchor.constraint(equalToConstant: estimatedWriterLabelWidth)
        writerLabelWidthNSConstraint?.isActive = true
    }
    
    private func configureWrittenTimeLabel(writtenTime: String) {
        let writtenDate = Date.createdDateTimeToDate(writtenTime)
        writtenTimeLabel.text = "• \(formatDateToString(date: writtenDate)) •"
    }
    
    private func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return dateFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else {
            dateFormatter.dateFormat = "yy-MM-dd"
            return dateFormatter.string(from: date)
        }
    }
    
    func changeDuplicatedTextColor(searchText: String) {
        changeColorOfTextInLabel(searchText: searchText, targetLabel: titleLabel)
    }
    
    private func changeColorOfTextInLabel(searchText: String, targetLabel: UILabel) {
        let originalText = targetLabel.text ?? ""
        
        let attributedText = NSMutableAttributedString(string: originalText)
        
        let range = (originalText as NSString).range(of: searchText, options: .caseInsensitive)
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemRed, range: range)
        
        targetLabel.attributedText = attributedText
    }

}
