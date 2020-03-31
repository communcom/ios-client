//
//  UIViewControllerExtension.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import MBProgressHUD
import ReCaptcha
import SafariServices
import StoreKit

public let reCaptchaTag: Int = 777

protocol NextButtonBottomConstraint {
    var nextButtonBottomConstraint: NSLayoutConstraint! { get set }
}

extension UIViewController {
    // MARK: - Properties
    var baseNavigationController: BaseNavigationController? {
        navigationController as? BaseNavigationController
    }
        
    var hintView: CMHint? {
        get {
            let hintViewInstance = CMHint(type: .enterText, isTabbarHidden: tabBarController?.tabBar.isHidden ?? true)
            view.addSubview(hintViewInstance)
            return hintViewInstance
        }
    }

    // MARK: - Custom Functions
    static func fromStoryboard(_ storyboard: String, withIdentifier identifier: String) -> Self {
        let st = UIStoryboard(name: storyboard, bundle: nil)
        return st.instantiateViewController(withIdentifier: identifier) as! Self
    }
    
    func showActionSheet(title: String? = nil, message: String? = nil, actions: [UIAlertAction] = [], cancelCompletion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for action in actions {
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized().uppercaseFirst, style: .cancel, handler: {_ in
            cancelCompletion?()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCommunActionSheet(headerView: UIView? = nil,
                               title: String? = nil,
                               titleFont: UIFont = .systemFont(ofSize: 15, weight: .semibold),
                               titleAlignment: NSTextAlignment = .left,
                               actions: [CommunActionSheet.Action],
                               completion: (() -> Void)? = nil) {

        let actionSheet = CommunActionSheet()
        actionSheet.title = title
        actionSheet.headerView = headerView
        actionSheet.actions = actions
        actionSheet.titleFont = titleFont
        actionSheet.textAlignment = titleAlignment
        
        actionSheet.modalPresentationStyle = .custom
        actionSheet.transitioningDelegate = actionSheet
        present(actionSheet, animated: true, completion: completion)
    }
    
    func showGeneralError() {
        showErrorWithLocalizedMessage("Something went wrong.\nPlease try again later")
    }
    
    func showErrorWithMessage(_ message: String, completion: (() -> Void)? = nil) {
        let vc = tabBarController ?? navigationController ?? parent ?? self
        
        vc.showAlert(title: "error".localized().uppercaseFirst, message: message, buttonTitles: ["OK".localized().uppercaseFirst]) { (_) in
            completion?()
        }
    }
    
    func showErrorWithLocalizedMessage(_ message: String, completion: (() -> Void)? = nil) {
        showErrorWithMessage(message.localized(), completion: completion)
    }
    
    func showError(_ error: Error, showPleaseTryAgain: Bool = false, additionalMessage: String? = nil, completion: (() -> Void)? = nil) {
        let message = error.localizedDescription
        showErrorWithLocalizedMessage(message + (showPleaseTryAgain ? (".\n" + "please try again later".localized().uppercaseFirst + "!"): "") + (additionalMessage ?? ""), completion: completion)
    }
    
    func hideHud() {
        let vc = tabBarController ?? navigationController ?? parent ?? self
        
        MBProgressHUD.hide(for: vc.view, animated: false)
    }
    
    func showIndetermineHudWithMessage(_ message: String?) {
        let vc = tabBarController ?? navigationController ?? parent ?? self
        
        // Hide all previous hud
        hideHud()
        
        // show new hud
        let hud = MBProgressHUD.showAdded(to: vc.view, animated: false)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.isUserInteractionEnabled = true
        hud.label.text = message
        hud.backgroundColor = UIColor(white: 0, alpha: 0.2)

    }
    
    func showDone(_ message: String, completion: (() -> Void)? = nil) {
        let vc = tabBarController ?? navigationController ?? parent ?? self
        
        // Hide all previous hud
        hideHud()
        
        // show new hud
        let hud = MBProgressHUD.showAdded(to: vc.view, animated: false)
        hud.mode = .customView
        let image = UIImage(named: "checkmark-large")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .black
        hud.customView = imageView
        hud.label.text = message.localized()
        hud.hide(animated: true, afterDelay: 1)
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: completion)
        }
    }
    
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func showProfileWithUserId(_ userId: String?, username: String? = nil) {
        // if profile was opened, shake it off!!
//        if let profileVC = self as? UserProfilePageVC, profileVC.userId == userId {
//            profileVC.view.shake()
//            return
//        }
        
        // Open other user's profile
        if userId != Config.currentUser?.id && username != Config.currentUser?.name {
            let profileVC = UserProfilePageVC(userId: userId, username: username)
            show(profileVC, sender: nil)
            return
        } else {
            let profileVC = MyProfilePageVC()
            profileVC.shouldHideBackButton = false 
            show(profileVC, sender: nil)
        }
        
        // my profile
//        view.shake()
//        if let profileNC = tabBarController?.viewControllers?.first(where: {($0 as? UINavigationController)?.viewControllers.first is MyProfilePageVC}),
//            profileNC != tabBarController?.selectedViewController,
//            let tabBarVC = tabBarController as? TabBarVC
//        {
//            tabBarVC.switchTab(index: tabBarVC.profileTabIndex)
//            tabBarVC.selectedViewController?.view.shake()
//        } else {
//            self.view.shake()
//        }
    }
    
    func navigateWithNotificationItem(_ item: ResponseAPIGetNotificationItem) {
        switch item.eventType {
        case "subscribe":
            if let id = item.user?.userId {
                showProfileWithUserId(id)
            }
        
        case "upvote", "reply", "mention":
            switch item.entityType {
            case "post":
                if let userId = item.post?.contentId.userId,
                    let permlink = item.post?.contentId.permlink,
                    let communityId = item.post?.contentId.communityId
                {
                    let postVC = PostPageVC(userId: userId, permlink: permlink, communityId: communityId)
                    show(postVC, sender: self)
                }
            
            case "comment":
                if let userId = item.comment?.parents?.post?.userId,
                    let permlink = item.comment?.parents?.post?.permlink,
                    let communityId = item.comment?.parents?.post?.communityId
                {
                    let postVC = PostPageVC(userId: userId, permlink: permlink, communityId: communityId)
                    show(postVC, sender: self)
                }
           
            default:
                break
            }
        
        case "transfer":
            if item.from?.username == nil {
                if let id = item.community?.communityId {
                    showCommunityWithCommunityId(id)
                }
            } else if item.from?.username?.lowercased() != "bounty" {
                if let id = item.from?.userId {
                    showProfileWithUserId(id)
                }
            } else {
                if let id = item.community?.communityId {
                    showOtherBalanceWalletVC(symbol: id)
                }
            }
            
        case "reward", "referralRegistrationBonus", "referralPurchaseBonus":
            showOtherBalanceWalletVC(symbol: item.community?.communityId,
                                     shouldResetNavigationBarOnPush: true)
        default:
            break
        }
    }
    
    func showCommunityWithCommunityId(_ id: String) {
        if let vc = self as? CommunityPageVC, vc.communityId == id {
            vc.view.shake()
            return
        }
        let communityVC = CommunityPageVC(communityId: id)
        show(communityVC, sender: nil)
    }
    
    func showCommunityWithCommunityAlias(_ alias: String) {
        if let vc = self as? CommunityPageVC, vc.communityAlias == alias {
            vc.view.shake()
            return
        }
        let communityVC = CommunityPageVC(communityAlias: alias)
        show(communityVC, sender: nil)
    }
    
    func showOtherBalanceWalletVC(symbol: String?, shouldResetNavigationBarOnPush: Bool = false) {
        var vc: UIViewController!

        if let symbol = symbol {
            vc = OtherBalancesWalletVC(symbol: symbol)
        } else {
            vc = CommunWalletVC()
        }
                
        if shouldResetNavigationBarOnPush {
            show(vc, sender: nil)
        } else {
            let nc = navigationController as? BaseNavigationController
            nc?.shouldResetNavigationBarOnPush = false
            show(vc, sender: nil)
            nc?.shouldResetNavigationBarOnPush = true
        }
    }
    
    func handleUrl(url: URL) {
        let path = Array(url.path.components(separatedBy: "/").dropFirst())
        
        // Check if link is a commun.com link
        if url.absoluteString.starts(with: URL.appURL) &&
            (path.count == 1 || path.count == 3)
        {
            if path.count == 1 {
                if path[0].starts(with: "@") {
                    // user's profile
                    let username = String(path[0].dropFirst())
                    showProfileWithUserId(nil, username: username)
                    return
                } else if !path[0].isEmpty {
                    // community
                    let alias = path[0]
                    showCommunityWithCommunityAlias(alias)
                    return
                } else if url.absoluteString.starts(with: URL.appURL + "/#"),
                    let hashtag = url.absoluteString.components(separatedBy: "#").last
                {
                    // hashtag
                    let vc = SearchablePostsVC(keyword: "#" + hashtag)
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(customView: UIView(backgroundColor: .clear))
                    self.baseNavigationController?.changeStatusBarStyle(.default)
                    self.show(vc, sender: self)
                    return
                }
            } else if path.count == 3 {
                let communityAlias = path[0]
                let username = String(path[1].dropFirst())
                let permlink = path[2]
                
                let postVC = PostPageVC(username: username, permlink: permlink, communityAlias: communityAlias)
                show(postVC, sender: nil)
                return
            }
        }

        var rightURL: URL? = url

        if !(["http", "https"].contains(url.scheme?.lowercased() ?? "")) {
            let link = "http://" + url.absoluteString
            rightURL = URL(string: link)
        }

        if let url = rightURL {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - ChildVC
    func add(_ child: UIViewController, to view: UIView? = nil) {
        addChild(child)
        
        if let frame = view?.frame {
            child.view.frame = frame
        }
        
        view?.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
   
    @objc func back() {
        popOrDismissVC()
    }

    @objc func leftButtonTapped() {
        popOrDismissVC()
    }

    @objc func rightButtonTapped() {
        popOrDismissVC()
    }

    func backCompletion(_ completion: @escaping (() -> Void)) {
        popOrDismissVC(completion)
    }
    
    fileprivate func popOrDismissVC(_ completion: (() -> Void)? = nil) {
        if let nc = navigationController, nc.viewControllers.first != self {
            nc.popViewController(animated: true, completion)
        } else {
            self.dismiss(animated: true, completion: completion)
        }
    }
    
    func setLeftNavBarButtonForGoingBack(tintColor: UIColor = .black) {
        setLeftBarButton(imageName: "icon-back-bar-button-black-default", tintColor: tintColor, action: #selector(back))
    }
    
    func setLeftBarButton(imageName: String, tintColor: UIColor = .black, action: Selector?) {
        let backButton = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: self, action: action)
        backButton.tintColor = tintColor
        navigationItem.leftBarButtonItem = backButton
    }

    func setRightBarButton(imageName: String, tintColor: UIColor = .black, action: Selector?) {
        let backButton = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: self, action: action)
        backButton.tintColor = tintColor
        navigationItem.rightBarButtonItem = backButton
    }

    func setLeftNavBarButton(with button: UIButton) {
        // backButton
        let leftButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 40))
        
        leftButtonView.addSubview(button)
        button.autoPinEdgesToSuperviewEdges()

        let leftBarButton = UIBarButtonItem(customView: leftButtonView)
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func setRightNavBarButton(with button: UIButton) {
        // backButton
        let rightButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 40))
        
        rightButtonView.addSubview(button)
        button.autoPinEdgesToSuperviewEdges()

        let rightBarButton = UIBarButtonItem(customView: rightButtonView)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setNavBarBackButton(title: String? = nil, tintColor: UIColor = .black) {
        let newBackButton = title == nil ?  UIBarButtonItem(image: UIImage(named: "icon-back-bar-button-black-default"), style: .plain, target: self, action: #selector(popToPreviousVC)) :
                                            UIBarButtonItem(title: title!.localized().uppercaseFirst, style: .plain, target: self, action: #selector(popToPreviousVC))
        
        if title == nil {
            newBackButton.tintColor = tintColor
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func showCardWithView(_ view: UIView) {
        let cardVC = CardViewController(contentView: view)
        self.present(cardVC, animated: true, completion: nil)
    }
    
    func showAttention(title: String = "attention".localized().uppercaseFirst, subtitle: String, descriptionText: String, backButtonLabel: String = "back".localized().uppercaseFirst, ignoreButtonLabel: String, ignoreAction: @escaping () -> Void, backAction: (() -> Void)? = nil)
    {
        let attentionView = AttentionView(
            title: title,
            subtitle: subtitle,
            descriptionText: descriptionText,
            backButtonLabel: backButtonLabel,
            ignoreButtonLabel: ignoreButtonLabel
        )
        attentionView.ignoreAction = ignoreAction
        attentionView.backAction = backAction
        showCardWithView(attentionView)
    }

    // MARK: - Actions
    @objc func popToPreviousVC() {
        if let count = navigationController?.viewControllers.count, count > 0 {
            let viewWithTag = self.view.viewWithTag(reCaptchaTag)
            
            if let previousVC = navigationController?.viewControllers[count - (viewWithTag == nil ? 2 : 1)] {
                navigationController?.popToViewController(previousVC, animated: true)
                viewWithTag?.removeFromSuperview()
            }
        }
    }

    func scrollToTop() {
         func scrollToTop(view: UIView?) {
             guard let view = view, !(view is CMTopTabBar) else { return }

             switch view {
             case let scrollView as UIScrollView:
                 if scrollView.scrollsToTop == true {
                     scrollView.setContentOffset(CGPoint(x: 0.0, y: -scrollView.contentInset.top), animated: true)
                     return
                 }
             default:
                 break
             }

             for subView in view.subviews {
                 scrollToTop(view: subView)
             }
         }

         scrollToTop(view: self.view)
     }
    
    func showNavigationBar(_ show: Bool, animated: Bool = false, completion: (() -> Void)? = nil) {
        navigationController?.navigationBar.addShadow(ofColor: .shadow, radius: 16, offset: CGSize(width: 0, height: 6), opacity: 0.05)
        baseNavigationController?.changeStatusBarStyle(show ? .default : .lightContent)
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.navigationController?.navigationBar.subviews.first?.backgroundColor = show ? .white: .clear
            self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color:
                show ? .black: .clear)
            self.navigationItem.leftBarButtonItem?.tintColor = show ? .black: .white
            completion?()
        }
    }
    
    func appLiked() {
        if !CMAppLike.verify() {
            CMAppLike.updateRate()

            let appLikeView = CMAppLikeView(withFrame: CGRect(origin: .zero, size: CGSize(width: 355.0, height: 192.0)),
                                            andParameters: .appLiked)
            
            let cardVC = CardViewController(contentView: appLikeView)
            
            self.present(cardVC, animated: true, completion: {
                AnalyticsManger.shared.showRate()
            })
            
            appLikeView.completionDismissWithAppLiked = { isLiked in
                self.dismiss(animated: true, completion: {
                    AnalyticsManger.shared.rate(isLike: isLiked)

                    if isLiked {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                            SKStoreReviewController.requestReview()
                        }
                    } else {
                        let vc = CMFeedbackViewController()
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
