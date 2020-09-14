//
//  EditCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 9/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class EditCommunityVC: BaseVerticalStackVC {
    var originalCommunity: ResponseAPIContentGetCommunity
    
    override var padding: UIEdgeInsets {UIEdgeInsets(top: 16, left: 10, bottom: 16, right: 10)}
    override var stackViewPadding: UIEdgeInsets {.zero}
    
    lazy var avatarImageView = MyAvatarImageView(size: 120)
    lazy var coverImageView = UIImageView(cornerRadius: 7, imageNamed: "cover-placeholder", contentMode: .scaleAspectFill)
    lazy var descriptionLabel = UILabel.with(textSize: 17, numberOfLines: 0)
    
    init(community: ResponseAPIContentGetCommunity) {
        self.originalCommunity = community
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        scrollView.contentView.backgroundColor = .appWhiteColor
        scrollView.contentView.cornerRadius = 10
        
        title = originalCommunity.name
        
        reloadData()
    }
    
    override func viewWillSetUpStackView() {
        stackView.spacing = 0
        stackView.alignment = .center
    }
    
    override func viewDidSetUpStackView() {
        stackViewTopConstraint?.isActive = false
        stackViewTopConstraint = stackView.autoPinEdge(toSuperviewEdge: .top)
    }
    
    override func setUpArrangedSubviews() {
        // avatar
        let avatarSectionHeaderView = sectionHeaderView(title: "avatar".localized().uppercaseFirst, action: #selector(avatarButtonDidTouch))
        stackView.addArrangedSubview(avatarSectionHeaderView)
        avatarSectionHeaderView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.addArrangedSubview(avatarImageView)
        
        stackView.setCustomSpacing(16, after: avatarImageView)
        
        // cover
        let coverSectionHeaderView = sectionHeaderView(title: "cover".localized().uppercaseFirst, action: #selector(coverButtonDidTouch))
        stackView.addArrangedSubview(coverSectionHeaderView)
        coverSectionHeaderView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.setCustomSpacing(5, after: coverSectionHeaderView)
        
        coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 335 / 150).isActive = true
        stackView.addArrangedSubview(coverImageView)
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -10).isActive = true
        
        stackView.setCustomSpacing(10, after: coverImageView)
        
        // separator
        let separator = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        stackView.addArrangedSubview(separator)
        separator.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // description
        let descriptionHeaderView = sectionHeaderView(title: "description".localized().uppercaseFirst, action: #selector(descriptionButtonDidTouch))
        stackView.addArrangedSubview(descriptionHeaderView)
        descriptionHeaderView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32).isActive = true
        
        // separator
        let separator2 = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        stackView.addArrangedSubview(separator2)
        separator2.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        // rules
        let rulesHeaderView = sectionHeaderView(title: "rules".localized().uppercaseFirst, action: #selector(rulesButtonDidTouch))
        stackView.addArrangedSubview(rulesHeaderView)
        rulesHeaderView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
    
    func reloadData() {
        avatarImageView.setAvatar(urlString: originalCommunity.avatarUrl)
        coverImageView.setCover(urlString: originalCommunity.coverUrl)
        descriptionLabel.text = originalCommunity.description
    }
    
    fileprivate func sectionHeaderView(title: String, action: Selector? = nil) -> UIStackView {
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        stackView.autoSetDimension(.height, toSize: 55)
        let label = UILabel.with(text: title, textSize: 17, weight: .semibold)
        let arrow = UIButton.nextArrow()
        stackView.addArrangedSubviews([label, arrow])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        arrow.isHidden = true
        if let action = action {
            arrow.addTarget(self, action: action, for: .touchUpInside)
            arrow.isHidden = false
        }
        
        return stackView
    }
    
    // MARK: - Action
    @objc func avatarButtonDidTouch() {
        
    }
    
    @objc func coverButtonDidTouch() {
        
    }
    
    @objc func descriptionButtonDidTouch() {
        
    }
    
    @objc func rulesButtonDidTouch() {
        
    }
}
