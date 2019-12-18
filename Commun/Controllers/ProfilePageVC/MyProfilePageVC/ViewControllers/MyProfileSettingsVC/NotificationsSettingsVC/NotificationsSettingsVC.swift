//
//  NotificationsSettingsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class NotificationsSettingsVC: BaseVerticalStackViewController {
    // MARK: - Subviews
    lazy var closeButton = UIButton.close()
    lazy var notificationOnAction: NotificationSettingsView = {
        let view = viewForAction(
            Action(title: "notifications".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention"))
        ) as! NotificationSettingsView
        view.switchButton.addTarget(self, action: #selector(toggleNotificationOn(_:)), for: .valueChanged)
        view.cornerRadius = 10
        return view
    }()
    
    // MARK: - Properties
    var viewModel = NotificationSettingsViewModel()
    
    // MARK: - Initializers
    init() {
        super.init(actions: [
            Action(title: "upvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_upvote")),
            Action(title: "downvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_downvote")),
            Action(title: "points transfer".localized().uppercaseFirst, icon: UIImage(named: "profile_options_points_transfer")),
            Action(title: "comment and reply".localized().uppercaseFirst, icon: UIImage(named: "profile_options_comment_and_reply")),
            Action(title: "mention".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention")),
            Action(title: "rewards for post".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_post")),
            Action(title: "rewards for vote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_vote")),
            Action(title: "following".localized().uppercaseFirst, icon: UIImage(named: "profile_options_following"))
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
        closeButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
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
    
    override func viewForAction(_ action: Action) -> UIView {
        let actionView = NotificationSettingsView(height: 65, backgroundColor: .white)
        actionView.setUp(with: action)
        return actionView
    }
    
    @objc func toggleNotificationOn(_ switcher: UISwitch) {
        viewModel.togglePushNotify(on: switcher.isOn)
    }
}
