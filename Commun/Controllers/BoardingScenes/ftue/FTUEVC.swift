//
//  FTUEVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FTUEVC: BaseViewController {
    // MARK: - Subviews
    lazy var containerView = UIView(forAutoLayout: ())
    lazy var pageControl = CMPageControll(numberOfPages: 2)
    
    // MARK: - SubViewControllers
    private lazy var communitiesVC = FTUECommunitiesVC()
    
    private lazy var authorizeOnWebVC: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .blue
        return vc
    }()
    
    // MARK: - Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .white
        
        let communLabel = UILabel.with(text: "commun", textSize: 20, weight: .bold)
        view.addSubview(communLabel)
        communLabel.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        communLabel.autoPinEdge(toSuperviewSafeArea: .top, withInset: 10)
        
        let icon = UILabel.with(text: "/", textSize: 24, weight: .bold, textColor: .appMainColor)
        view.addSubview(icon)
        icon.autoPinEdge(.leading, to: .trailing, of: communLabel, withOffset: 4)
        icon.autoAlignAxis(.horizontal, toSameAxisOf: communLabel)
        
        view.addSubview(containerView)
        containerView.autoPinEdge(.top, to: .bottom, of: communLabel, withOffset: 20)
        containerView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        
        view.addSubview(pageControl)
        pageControl.autoAlignAxis(.horizontal, toSameAxisOf: communLabel)
        pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
        
        add(childVC: communitiesVC)
    }
    
    private func showAuthorizeOnWebVC() {
        pageControl.selectedIndex = 1
        remove(childVC: communitiesVC)
        add(childVC: authorizeOnWebVC)
    }
    
    private func add(childVC: UIViewController) {
        addChildViewController(childVC, toContainerView: containerView)
        
        childVC.view.frame = containerView.bounds
        childVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func remove(childVC: UIViewController) {
        childVC.removeViewAndControllerFromParentViewController()
    }
}
