//
//  NotificationsSettingsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class NotificationsSettingsVC: BaseVerticalStackViewController {
    // MARK: - Subviews
    let closeButton = UIButton.circleGray(imageName: "close-x")
    
    // MARK: - Properties
    var viewModel = NotificationSettingsViewModel()
    
    override var actions: [CommunActionSheet.Action] {
        return [
            CommunActionSheet.Action(title: "upvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_upvote"), handle: {
                
            }),
            CommunActionSheet.Action(title: "downvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_downvote"), handle: {
                
            }),
            CommunActionSheet.Action(title: "points transfer".localized().uppercaseFirst, icon: UIImage(named: "profile_options_points_transfer"), handle: {
                
            }),
            CommunActionSheet.Action(title: "comment and reply".localized().uppercaseFirst, icon: UIImage(named: "profile_options_comment_and_reply"), handle: {
                
            }),
            CommunActionSheet.Action(title: "mention".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention"), handle: {
                
            }),
            CommunActionSheet.Action(title: "rewards for post".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_post"), handle: {
                
            }),
            CommunActionSheet.Action(title: "rewards for vote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_vote"), handle: {
                
            }),
            CommunActionSheet.Action(title: "following".localized().uppercaseFirst, icon: UIImage(named: "profile_options_following"), handle: {
                
            }),
        ]
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        title = "notifications".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    override func stackViewWithActions(actions: [CommunActionSheet.Action]) -> UIStackView {
        let stackView = UIStackView(axis: .vertical, spacing: 2)
        for action in actions {
            let actionView = UIView(height: 65, backgroundColor: .white)
            
            let imageView = UIImageView(width: 35, height: 35)
            imageView.image = action.icon
            actionView.addSubview(imageView)
            imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let label = UILabel.with(text: action.title, textSize: 17)
            actionView.addSubview(label)
            label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            let switchButton = UISwitch()
            switchButton.onTintColor = .appMainColor
            actionView.addSubview(switchButton)
            switchButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            switchButton.autoAlignAxis(toSuperviewAxis: .horizontal)
            switchButton.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 10)
            
            stackView.addArrangedSubview(actionView)
            actionView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
                .isActive = true
        }
        return stackView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
