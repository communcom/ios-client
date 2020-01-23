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
    
    // MARK: - Properties
    var viewModel = NotificationSettingsViewModel()
    
    // MARK: - Initializers
    init() {
        super.init(actions: [
            Action(title: "upvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_upvote")),
//            Action(title: "downvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_downvote")),
//            Action(title: "points transfer".localized().uppercaseFirst, icon: UIImage(named: "profile_options_points_transfer")),
            Action(title: "reply".localized().uppercaseFirst, icon: UIImage(named: "profile_options_comment_and_reply")),
            Action(title: "mention".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention")),
//            Action(title: "rewards for post".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_post")),
//            Action(title: "rewards for vote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_vote")),
            Action(title: "subscribe".localized().uppercaseFirst, icon: UIImage(named: "profile_options_following"))
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
        
        // loadingState
        viewModel.loadingState
            .subscribe(onNext: {[weak self] (state) in
                switch state {
                case .loading:
                    self?.stackView.showLoader()
                case .finished:
                    self?.stackView.hideLoader()
                case .error(let error):
                    #if !APPSTORE
                    self?.showError(error)
                    #endif
                    self?.stackView.hideLoader()
                    self?.view.showErrorView {
                        self?.view.hideErrorView()
                        self?.viewModel.getSettings()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // disabledType
        viewModel.disabledTypes
            .subscribe(onNext: { (disabledTypes) in
                
            })
            .disposed(by: disposeBag)
    }
    
    override func viewForAction(_ action: Action) -> UIView {
        let actionView = NotificationSettingsView(height: 65, backgroundColor: .white)
        var notificationType = ""
        switch action.title {
        case "upvote".localized().uppercaseFirst:
            notificationType = "upvote"
        case "reply".localized().uppercaseFirst:
            notificationType = "reply"
        case "mention".localized().uppercaseFirst:
            notificationType = "mention"
        case "subscribe".localized().uppercaseFirst:
            notificationType = "subscribe"
        default:
            break
        }
        actionView.notificationType = notificationType
        actionView.setUp(with: action)
        actionView.delegate = self
        return actionView
    }
}

extension NotificationsSettingsVC: NotificationSettingsViewDelegate {
    func notificationSettingsView(_ notificationSettingsView: NotificationSettingsView, didChangeValueForSwitch switcher: UISwitch, forNotificationType type: String) {
        print(switcher.isOn)
    }
}
