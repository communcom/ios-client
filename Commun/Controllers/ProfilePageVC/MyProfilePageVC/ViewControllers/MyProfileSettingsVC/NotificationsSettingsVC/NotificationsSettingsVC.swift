//
//  NotificationsSettingsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class NotificationsSettingsVC: BaseVerticalStackViewController, PNAlertViewDelegate {
    // MARK: - Subviews
    lazy var closeButton = UIButton.close()
    var pnAlertView: PNAlertView?
    
    // MARK: - Properties
    var viewModel = NotificationSettingsViewModel()
    var settingViews: [NotificationSettingsView] {
        stackView.arrangedSubviews.compactMap {$0 as? NotificationSettingsView}
    }
    
    var switchers: [UISwitch] {
        settingViews.map {$0.switchButton}
    }
    
    // MARK: - Initializers
    init() {
        super.init(actions: [
            Action(title: "upvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_upvote")),
//            Action(title: "downvote".localized().uppercaseFirst, icon: UIImage(named: "profile_options_downvote")),
            Action(title: "transfer".localized().uppercaseFirst, icon: UIImage(named: "profile_options_points_transfer")),
            Action(title: "reply".localized().uppercaseFirst, icon: UIImage(named: "profile_options_comment_and_reply")),
            Action(title: "mention".localized().uppercaseFirst, icon: UIImage(named: "profile_options_mention")),
            Action(title: "reward".localized().uppercaseFirst, icon: UIImage(named: "profile_options_rewards_for_post")),
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
        closeButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        
        checkPNAuthorizationStatus()
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
            .subscribe(onNext: { [weak self] (disabledTypes) in
                guard let strongSelf = self else {return}
                for view in strongSelf.settingViews {
                    view.switchButton.isOn = !disabledTypes.contains(view.notificationType)
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
        case "transfer".localized().uppercaseFirst:
            notificationType = "transfer"
        case "reward".localized().uppercaseFirst:
            notificationType = "reward"
        default:
            break
        }
        actionView.notificationType = notificationType
        actionView.setUp(with: action)
        actionView.delegate = self
        return actionView
    }
    
    // MARK: - PNAlertViewDelegate
    var pnAlertViewShowed: Bool {
        pnAlertView?.isDescendant(of: view) ?? false
    }
    
    func clearPNAlertView() {
        pnAlertView?.removeFromSuperview()
        pnAlertView = nil
        
        stackViewTopConstraint?.isActive = false
        stackViewTopConstraint = stackView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        UIView.animate(withDuration: 0.3) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
    func showPNAlertView() {
        stackViewTopConstraint?.isActive = false
        
        pnAlertView = PNAlertView(forAutoLayout: ())
        pnAlertView?.delegate = self
        scrollView.contentView.addSubview(pnAlertView!)
        
        pnAlertView?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .bottom)
        stackViewTopConstraint = pnAlertView?.autoPinEdge(.bottom, to: .top, of: stackView, withOffset: -16)
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.layoutIfNeeded()
        }
    }
    
    // MARK: - AppState observer
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        checkPNAuthorizationStatus()
    }
}

extension NotificationsSettingsVC: NotificationSettingsViewDelegate {
    func notificationSettingsView(_ notificationSettingsView: NotificationSettingsView, didChangeValueForSwitch switcher: UISwitch, forNotificationType type: String) {
        var disabledTypes = [String]()
        for view in settingViews {
            if !view.switchButton.isOn {disabledTypes.append(view.notificationType)}
            
            // disable all button
            view.switchButton.isEnabled = false
        }
        
        RestAPIManager.instance.notificationsSetPushSettings(disable: disabledTypes)
            .subscribe(onSuccess: { [weak self] (_) in
                self?.switchers.forEach {$0.isEnabled = true}
            }) { [weak self] (error) in
                guard let strongSelf = self else {return}
                strongSelf.showError(error)
                self?.switchers.forEach {$0.isEnabled = true}
                switcher.isOn = !switcher.isOn
            }
            .disposed(by: disposeBag)
    }
}
