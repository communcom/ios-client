//
//  TabBarVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import SwifterSwift

class TabBarVC: UITabBarController {
    // MARK: - Constants
    let feedTabIndex = 0
    let searchTabIndex = 1
    let notificationTabIndex = 2
    let profileTabIndex = 3
    let selectedColor = UIColor.black
    let unselectedColor = UIColor(hexString: "#E5E7ED")
    let tabBarHeight: CGFloat = 60
    
    // MARK: - Properties
    let viewModel = TabBarViewModel()
    let bag = DisposeBag()
    
    // MARK: - Subviews
    private lazy var tabBarContainerView = UIView(backgroundColor: .white)
    private lazy var shadowView = UIView(height: tabBarHeight)
    lazy var tabBarStackView = UIStackView(forAutoLayout: ())
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config styles
        configStyles()

        // Config tabs
        configTabs()
        
        // bind view model
        bindViewModel()
    }
    
    func setTabBarHiden(_ hide: Bool) {
        if hide {
            shadowView.isHidden = true
            shadowView.heightConstraint?.constant = 0
        }
        else {
            shadowView.isHidden = false
            shadowView.heightConstraint?.constant = tabBarHeight
        }
    }
    
    private func configStyles() {
        view.backgroundColor = .white
        
        // hide default tabBar
        tabBar.isHidden = true
        
        // shadow
        view.addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        shadowView.addShadow(ofColor: .shadow, radius: 4, offset: CGSize(width: 0, height: -6), opacity: 0.1)
        
        // tabBarContainerView
        shadowView.addSubview(tabBarContainerView)
        tabBarContainerView.autoPinEdgesToSuperviewEdges()
        
//
        // tabBarStackView
        tabBarContainerView.addSubview(tabBarStackView)
        tabBarStackView.autoPinEdgesToSuperviewEdges(with: .zero)
        tabBarStackView.axis = .horizontal
        tabBarStackView.alignment = .center
        tabBarStackView.distribution = .fillEqually
        tabBarStackView.spacing = 0
        
        // whiteView
        let whiteView = UIView(backgroundColor: .white)
        view.addSubview(whiteView)
        whiteView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        whiteView.autoPinEdge(.top, to: .bottom, of: tabBarStackView)
        view.bringSubviewToFront(tabBarContainerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // https://stackoverflow.com/questions/39578530/since-xcode-8-and-ios10-views-are-not-sized-properly-on-viewdidlayoutsubviews
        shadowView.layoutIfNeeded()
        tabBarContainerView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 24.5)
    }
    
    private func configTabs() {
        // Feed Tab
        let feed = controllerContainer.resolve(FeedPageVC.self)!
        let feedNC = BaseNavigationController(rootViewController: feed)
        let feedItem = buttonTabBarItem(image: UIImage(named: "feed")!, tag: feedTabIndex)
        feed.accessibilityLabel = "TabBarFeedTabBarItem"

        // Comunities Tab
        let comunities = CommunitiesVC(type: .all)
        let communitiesNC = BaseNavigationController(rootViewController: comunities)
        let communitiesItem = buttonTabBarItem(image: UIImage(named: "tabbar-community")!, tag: searchTabIndex)
        comunities.accessibilityLabel = "TabBarComunitiesTabBarItem"
        
        // Notifications Tab
        let notifications = NotificationsPageVC()
        let notificationsNC = BaseNavigationController(rootViewController: notifications)
        let notificationsItem = buttonTabBarItem(image: UIImage(named: "notifications")!, tag: notificationTabIndex)
        notificationsNC.navigationBar.prefersLargeTitles = true
        notifications.accessibilityLabel = "TabBarNotificationsTabBarItem"

        // Profile Tab
        let profile = MyProfilePageVC()
        let profileNC = BaseNavigationController(rootViewController: profile)
        let profileItem = buttonTabBarItem(image: UIImage(named: "tabbar-profile")!, tag: profileTabIndex)
        profileNC.accessibilityLabel = "TabBarProfileTabBarItem"
        profileNC.navigationBar.tintColor = UIColor.appMainColor

        // Set up controllers
        viewControllers = [feedNC, communitiesNC,/* wallet,*/ notificationsNC, profileNC]
        
        tabBarStackView.addArrangedSubviews([
            feedItem,
            communitiesItem,
            tabBarItemAdd,
            notificationsItem,
            profileItem
        ])
        
        // highlight first
        feedItem.tintColor = selectedColor
    }
    
    private func buttonTabBarItem(image: UIImage, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = unselectedColor
        button.tag = tag
        button.addTarget(self, action: #selector(switchTab(button:)), for: .touchUpInside)
        return button
    }
    
    var tabBarItemAdd: UIButton {
        let button = UIButton(type: .system)
        
        let view = UIView(width: 45, height: 45, backgroundColor: .appMainColor)
        view.cornerRadius = 45 / 2
        
        let imageView = UIImageView(image: UIImage(named: "add"))
        imageView.configureForAutoLayout()
        imageView.tintColor = .white
        
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        
        button.addSubview(view)
        view.autoAlignAxis(toSuperviewAxis: .vertical)
        view.autoAlignAxis(toSuperviewAxis: .horizontal)
        view.isUserInteractionEnabled = false
        view.addShadow(ofColor: UIColor(red: 106, green: 128, blue: 245)!, radius: 10, offset: CGSize(width: 0, height: 6), opacity: 0.35)
        
        button.tag = viewControllers!.count + 1
        button.addTarget(self, action: #selector(buttonAddTapped), for: .touchUpInside)
        return button
    }
    
    @objc func switchTab(button: UIButton) {
        switchTab(index: button.tag)
    }
    
    func switchTab(index: Int) {
        // pop to first if index is selected
        if selectedIndex == index {
            (viewControllers?[index] as? UINavigationController)?.popToRootViewController(animated: true)
            return
        }
        
        // change selected index
        selectedIndex = index
        
        // change tabs' color
        let items = tabBarStackView.arrangedSubviews.filter {$0.tag != (viewControllers?.count ?? 0) + 1}
        let selectedItem = items.first {$0.tag == selectedIndex}
        let unselectedItems = items.filter {$0.tag != selectedIndex}
        selectedItem?.tintColor = selectedColor
        for item in unselectedItems {
            item.tintColor = unselectedColor
        }
    }
    
    @objc func buttonAddTapped() {
        // open basic editor
        let vc = BasicEditorVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        // or select editor ???
//        showActionSheet(title: "choose an editor".localized().uppercaseFirst, actions: [
//            UIAlertAction(title: "basic editor".localized().uppercaseFirst, style: .default, handler: { (_) in
//                let vc = BasicEditorVC()
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }),
//            UIAlertAction(title: "article editor".localized().uppercaseFirst, style: .default, handler: { (_) in
//                let vc = ArticleEditorVC()
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }),
//        ])
    }

    func bindViewModel() {
        // Get number of fresh notifications
//        viewModel.getFreshCount()
//            .asDriver(onErrorJustReturn: 0)
//            .map {$0 > 0 ? "\($0)" : nil}
//            .drive(tabBar.items!.first(where: {$0.tag == 4})!.rx.badgeValue)
//            .disposed(by: bag)
    }
}
