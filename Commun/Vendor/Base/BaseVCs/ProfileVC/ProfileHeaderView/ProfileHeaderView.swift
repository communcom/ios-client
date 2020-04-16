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
    
    // MARK: - Subviews
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
    
    // MARK: - Properties
    var selectedIndex: BehaviorRelay<Int> {
        return segmentedControl.selectedIndex
    }
    
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = .white
        
        let headerStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        addSubview(headerStackView)
        headerStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .bottom)
        headerStackView.addArrangedSubviews([avatarImageView, headerLabel, followButton])
        
        addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        descriptionLabel.autoPinEdge(.top, to: .bottom, of: headerStackView, withOffset: 8)
        
        
        addSubview(statsStackView)
        statsStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        statsStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        statsStackView.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 14)
        
        statsStackView.addArrangedSubviews([statsLabel, usersStackView])
        
        willLayoutSegmentedControl()
        layoutSegmentedControl()
        
        let separator = UIView(height: 10, backgroundColor: .appLightGrayColor)
        addSubview(separator)
        
        separator.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        
        // pin bottom
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        followButton.addTarget(self, action: #selector(joinButtonDidTouch), for: .touchUpInside)
    }
    
    func willLayoutSegmentedControl() {
        
    }
    
    func layoutSegmentedControl() {
        addSubview(segmentedControl)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing)
    }
    
    override func reassignTableHeaderView() {
        super.reassignTableHeaderView()
        
        roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    @objc func joinButtonDidTouch() {
        
    }
}
