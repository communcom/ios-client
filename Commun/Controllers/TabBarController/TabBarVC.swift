//
//  TabBarVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class TabBarVC: UITabBarController {
    // MARK: - Constants
    let feedTabIndex = 0
    let searchTabIndex = 1
    let notificationTabIndex = 2
    let profileTabIndex = 3
    
    // MARK: - Constraint
    let selectedColor = UIColor.black
    let unselectedColor = UIColor(hexString: "#E5E7ED")
    let extraSpaceForTabBar: CGFloat = 14
    
    // MARK: - Properties
    let viewModel = TabBarViewModel()
    let bag = DisposeBag()
    
    // MARK: - Subviews
    private lazy var tabBarContainerView: UIView = UIView(backgroundColor: .white)
    lazy var tabBarStackView: UIStackView = UIStackView(forAutoLayout: ())
    var tabBarHeight: CGFloat {
        return tabBarContainerView.height
    }
    
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
    
    private func configStyles() {
        view.backgroundColor = .white
        
        // hide default tabBar
        tabBar.isHidden = true
        
        // tabBarContainerView
        view.addSubview(tabBarContainerView)
        tabBarContainerView.autoPinEdge(toSuperviewEdge: .trailing)
        tabBarContainerView.autoPinEdge(toSuperviewEdge: .leading)
        tabBarContainerView.autoPinEdge(toSuperviewEdge: .bottom)
        tabBarContainerView.autoPinEdge(.top, to: .top, of: tabBar)
        tabBarContainerView.cornerRadius = 24.5
        tabBarContainerView.addShadow(ofColor: UIColor(red: 56, green: 60, blue: 71)!, radius: 4, offset: CGSize(width: 0, height: -6), opacity: 0.1)
        // tabBarStackView
        tabBarContainerView.addSubview(tabBarStackView)
        tabBarStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        tabBarStackView.autoSetDimension(.height, toSize: tabBar.size.height + extraSpaceForTabBar)
        tabBarStackView.axis = .horizontal
        tabBarStackView.alignment = .center
        tabBarStackView.distribution = .fillEqually
        tabBarStackView.spacing = 0
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tabBar.frame.size.height = tabBar.frame.size.height + extraSpaceForTabBar
        tabBar.frame.origin.y = view.frame.height - tabBar.frame.size.height
    }
    
    private func configTabs() {
        // Feed Tab
        let feed = controllerContainer.resolve(FeedPageVC.self)!
        let feedNC = SwipeNavigationController(rootViewController: feed)
        let feedItem = buttonTabBarItem(image: UIImage(named: "feed")!, tag: feedTabIndex)
        feed.accessibilityLabel = "TabBarFeedTabBarItem"

        // Comunities Tab
        let comunities = controllerContainer.resolve(CommunitiesVC.self)!
        let communitiesNC = SwipeNavigationController(rootViewController: comunities)
        let communitiesItem = buttonTabBarItem(image: UIImage(named: "tabbar-search")!, tag: searchTabIndex)
        comunities.accessibilityLabel = "TabBarComunitiesTabBarItem"
        
        // Notifications Tab
        let notifications = NotificationsPageVC()
        let notificationsNC = SwipeNavigationController(rootViewController: notifications)
        let notificationsItem = buttonTabBarItem(image: UIImage(named: "notifications")!, tag: notificationTabIndex)
        notificationsNC.navigationBar.prefersLargeTitles = true
        notifications.accessibilityLabel = "TabBarNotificationsTabBarItem"

        // Profile Tab
        let profile = controllerContainer.resolve(ProfilePageVC.self)!
        let profileNC = SwipeNavigationController(rootViewController: profile)
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
