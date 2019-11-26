//
//  FTUEVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FTUEVC: BaseViewController, BoardingRouter {
    // MARK: - Subviews
    lazy var containerView = UIView(forAutoLayout: ())
    
    // MARK: - SubViewControllers
    private lazy var communitiesVC: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        return vc
    }()
    
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
    }
    
    private func add(childVC: UIViewController) {
        addChildViewController(childVC, toContainerView: containerView)
    }
    
    private func remove(childVC: UIViewController) {
        childVC.removeViewAndControllerFromParentViewController()
    }
}
