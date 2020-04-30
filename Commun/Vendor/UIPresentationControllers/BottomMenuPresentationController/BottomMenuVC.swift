//
//  BottomMenuVC.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class BottomMenuVC: BaseViewController {
    lazy var closeButton = UIButton.close(size: 30)
    lazy var titleLabel = UILabel.with(textSize: 15, weight: .semibold)
    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
        view.backgroundColor = .appWhiteColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.addSubview(titleLabel)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        view.addSubview(closeButton)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        closeButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
    }
}

extension BottomMenuVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomMenuPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
