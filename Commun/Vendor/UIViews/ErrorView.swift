//
//  ErrorView.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ErrorView: MyView {
    lazy var label = UIButton(label: "there is an error occurred".localized().uppercaseFirst + "\n" + "tap to try again".localized().uppercaseFirst, textColor: .darkGray)
    
    var retryAction: (()->Void)?
    init(retryAction: (()->Void)?) {
        super.init(frame: .zero)
        self.retryAction = retryAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        
        label.titleLabel?.lineBreakMode = .byWordWrapping
        label.titleLabel?.textAlignment = .center
        
        addSubview(label)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        label.autoAlignAxis(toSuperviewAxis: .vertical)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        label.addTarget(self, action: #selector(retryDidTouch(_:)), for: .touchUpInside)
    }
    
    @objc func retryDidTouch(_ sender: UIButton) {
        retryAction?()
    }
}
