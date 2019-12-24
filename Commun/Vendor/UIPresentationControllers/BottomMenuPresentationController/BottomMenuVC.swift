//
//  BottomMenuVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class BottomMenuVC: BaseViewController {
    lazy var contentView = UIView(forAutoLayout: ())
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
    }
}

extension BottomMenuVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
