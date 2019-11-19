//
//  NotificationsSettingsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class NotificationsSettingsVC: BaseVerticalStackViewController {
    // MARK: - Subviews
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    lazy var notificationOnAction: NotificationSettingsView = {
        let view = viewForAction(
            Action(title: "notifications".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention"), handle: {
                // TODO: Toggle notifications on/off
            })
        )
        view.switchButton.addTarget(self, action: #selector(toggleNotificationOn(_:)), for: .valueChanged)
        view.cornerRadius = 10
        return view
    }()
    
    // MARK: - Properties
    var viewModel = NotificationSettingsViewModel()
    let disposeBag = DisposeBag()
    
    // MARK: - Initializers
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
    
    override func bind() {
        super.bind()
        viewModel.notificationOn
            .filter {$0 != self.notificationOnAction.switchButton.isOn}
            .asDriver(onErrorJustReturn: true)
            .drive(notificationOnAction.switchButton.rx.isOn)
            .disposed(by: disposeBag)
        
        
        
        
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
    
    func viewForAction(_ action: Action) -> NotificationSettingsView {
        let actionView = NotificationSettingsView(height: 65, backgroundColor: .white)
        actionView.setUp(with: action)
        return actionView
    }
    
    @objc func toggleNotificationOn(_ switcher: UISwitch) {
        viewModel.togglePushNotify(on: switcher.isOn)
    }
}
