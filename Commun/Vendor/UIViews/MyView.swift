//
//  MyView.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension UIView {
    @objc func padding(_ inset: UIEdgeInsets) -> UIView {
        let view = UIView(forAutoLayout: ())
        view.addSubview(self)
        autoPinEdgesToSuperviewEdges(with: inset)
        return view
    }
}

class MyView: UIView {
    private var _paddingView: UIView?
    var paddingView: UIView {
        _paddingView ?? self
    }
    override func padding(_ inset: UIEdgeInsets) -> UIView {
        let view = super.padding(inset)
        _paddingView = view
        return view
    }
    
    // MARK: - Class Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    // MARK: - Custom Functions
    func commonInit() {
        
    }
}
