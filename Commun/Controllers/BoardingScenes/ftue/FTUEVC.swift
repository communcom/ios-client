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
    
    private lazy var authorizeOnWebVC: AuthorizeOnWebVC = {
        let vc = AuthorizeOnWebVC()
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
    
    override func bind() {
        super.bind()
        UserDefaults.standard.rx
            .observe(Bool.self, Config.currentUserDidSubscribeToMoreThan3Communities)
            .filter {$0 == true}
            .take(1)
            .subscribe(onNext: { (_) in
                self.showAuthorizeOnWebVC()
            })
            .disposed(by: disposeBag)
    }
    
    private func showAuthorizeOnWebVC() {
        pageControl.selectedIndex = 1
        UIView.animate(withDuration: 0.3) {
            self.remove(childVC: self.communitiesVC)
            self.add(childVC: self.authorizeOnWebVC)
        }
        
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
