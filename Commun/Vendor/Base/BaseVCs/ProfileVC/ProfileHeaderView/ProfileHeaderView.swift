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
    lazy var stackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
    
    lazy var headerStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var avatarImageView = MyAvatarImageView(size: 50)
    lazy var headerLabel = UILabel.with(text: "username", numberOfLines: 0)
    lazy var followButton = CommunButton.default(label: "follow".localized().uppercaseFirst)
    
    lazy var descriptionLabel = UILabel.with(text: "description", textSize: 14, numberOfLines: 0)

    lazy var statsStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var statsLabel = UILabel.with(text: "followers and following", numberOfLines: 0)
    lazy var usersStackView = UsersStackView(height: 34)
    
    lazy var segmentedControl: CMSegmentedControl = {
        let segmentedControl = CMSegmentedControl(height: 46, backgroundColor: .clear)
        segmentedControl.backgroundColor = .clear
        return segmentedControl
    }()
    
    lazy var bottomSeparator = UIView(height: 10, backgroundColor: .appLightGrayColor)
    
    // MARK: - Properties
    var selectedIndex: BehaviorRelay<Int> {
        return segmentedControl.selectedIndex
    }
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = .appWhiteColor
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
        
        headerStackView.addArrangedSubviews([avatarImageView, headerLabel, followButton])
        headerStackView.setCustomSpacing(4, after: headerLabel)
        statsStackView.addArrangedSubviews([statsLabel, usersStackView])
        
        addSubview(segmentedControl)
        segmentedControl.autoPinEdge(.top, to: .bottom, of: stackView)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing)
        
        addSubview(bottomSeparator)
        bottomSeparator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        bottomSeparator.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        
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
