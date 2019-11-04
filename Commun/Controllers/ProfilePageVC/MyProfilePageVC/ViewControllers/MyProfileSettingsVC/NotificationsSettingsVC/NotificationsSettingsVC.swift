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
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    lazy var notificationOnAction: UIView = {
        let view = viewForAction(
            Action(title: "notifications".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention"), handle: {
                // TODO: Toggle notifications on/off
            })
        )
        view.cornerRadius = 10
        return view
    }()
    
    // MARK: - Properties
    var viewModel = NotificationSettingsViewModel()
    
    init() {
        super.init(actions: [
            Action(title: "upvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_upvote"), handle: {
                
            }),
            Action(title: "downvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_downvote"), handle: {
                
            }),
            Action(title: "points transfer".localized().uppercaseFirst, icon: UIImage(named: "profile_options_points_transfer"), handle: {
                
            }),
            Action(title: "comment and reply".localized().uppercaseFirst, icon: UIImage(named: "profile_options_comment_and_reply"), handle: {
                
            }),
            Action(title: "mention".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention"), handle: {
                
            }),
            Action(title: "rewards for post".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_post"), handle: {
                
            }),
            Action(title: "rewards for vote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_vote"), handle: {
                
            }),
            Action(title: "following".localized().uppercaseFirst, icon: UIImage(named: "profile_options_following"), handle: {
                
            })
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        title = "notifications".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    override func layout() {
        scrollView.contentView.addSubview(notificationOnAction)
        notificationOnAction.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10), excludingEdge: .bottom)
        
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10), excludingEdge: .top)
        stackView.autoPinEdge(.top, to: .bottom, of: notificationOnAction, withOffset: 20)
    }
    
    override func setUpStackView() {
        for action in actions {
            let actionView = viewForAction(action)
            stackView.addArrangedSubview(actionView)
            actionView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
                .isActive = true
        }
    }
    
    func viewForAction(_ action: Action) -> UIView {
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
        return actionView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
