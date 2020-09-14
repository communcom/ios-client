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
    }
    
    override func viewWillSetUpStackView() {
        stackView.spacing = 0
        stackView.alignment = .center
    }
    
    override func setUpArrangedSubviews() {
        // avatar
        let avatarSectionHeaderView = sectionHeaderView(title: "avatar".localized().uppercaseFirst, action: #selector(avatarButtonDidTouch))
        stackView.addArrangedSubview(avatarSectionHeaderView)
        avatarSectionHeaderView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        let avatarImageView = MyAvatarImageView(size: 120)
        stackView.addArrangedSubview(avatarImageView)
        
        stackView.setCustomSpacing(16, after: avatarImageView)
        
        // cover
        let coverSectionHeaderView = sectionHeaderView(title: "cover".localized().uppercaseFirst, action: #selector(coverButtonDidTouch))
        stackView.addArrangedSubview(coverSectionHeaderView)
        coverSectionHeaderView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        
        stackView.setCustomSpacing(5, after: coverSectionHeaderView)
        
        let coverImageView = UIImageView(cornerRadius: 7, imageNamed: "cover-placeholder")
        coverImageView.widthAnchor.constraint(equalTo: coverImageView.heightAnchor, multiplier: 335 / 150).isActive = true
        stackView.addArrangedSubview(coverImageView)
        coverImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -10).isActive = true
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
}
