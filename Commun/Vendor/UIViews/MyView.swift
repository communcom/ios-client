//
//  MyView.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyView: UIView {
    private var _wrappingView: UIView?
    var wrappingView: UIView {
        _wrappingView ?? self
    }
    func wrapping(inset: UIEdgeInsets) -> UIView {
        let view = UIView(forAutoLayout: ())
        view.addSubview(self)
        autoPinEdgesToSuperviewEdges(with: inset)
        _wrappingView = view
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
