//
//  ProfileHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileHeaderView: MyTableHeaderView {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let statsSeparator = " • "
    
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .leading, distribution: .fill)
    
    lazy var headerStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var headerLabel = UILabel.with(numberOfLines: 0)
    lazy var followButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    
    lazy var descriptionLabel = UILabel.with(textSize: 14, numberOfLines: 0)

    lazy var statsStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var statsLabel = UILabel.with(numberOfLines: 0)
    lazy var usersStackView = UsersStackView(height: 34)
    
    lazy var segmentedControl: CMSegmentedControl = {
        let segmentedControl = CMSegmentedControl(height: 46, backgroundColor: .clear)
        segmentedControl.backgroundColor = .clear
        return segmentedControl
    }()
    
    lazy var separator = UIView(height: 10, backgroundColor: .appLightGrayColor)
    
    // MARK: - Properties
    var selectedIndex: BehaviorRelay<Int> {
        return segmentedControl.selectedIndex
    }
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = .white
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
        
        headerStackView.addArrangedSubviews([avatarImageView, headerLabel, followButton])
        statsStackView.addArrangedSubviews([statsLabel, usersStackView])
        
        followButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(statsLabelDidTouch(_:)))
        statsLabel.isUserInteractionEnabled = true
        statsLabel.addGestureRecognizer(tap)
    }
    
    override func reassignTableHeaderView() {
        super.reassignTableHeaderView()
        
        roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    @objc func joinButtonDidTouch() {
        
    }
    
    @objc func statsLabelDidTouch(_ gesture: UITapGestureRecognizer) {
        
    }
}
