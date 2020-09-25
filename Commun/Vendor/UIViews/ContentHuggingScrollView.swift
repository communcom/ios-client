//
//  ContentHuggingScrollView.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class ContentHuggingScrollView: UIScrollView {
    // MARK: - Subviews
    lazy var contentView = UIView(forAutoLayout: ())
    var scrollableAxis: NSLayoutConstraint.Axis
    
    // MARK: - Methods
    init(scrollableAxis: NSLayoutConstraint.Axis, contentInset: UIEdgeInsets = .zero) {
        self.scrollableAxis = scrollableAxis
        super.init(frame: .zero)
        self.contentInset = contentInset
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        configureForAutoLayout()
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        if scrollableAxis == .vertical {
            contentView.widthAnchor.constraint(equalTo: widthAnchor, constant: -(contentInset.left + contentInset.right) ).isActive = true
        } else {
            contentView.heightAnchor.constraint(equalTo: heightAnchor, constant: -(contentInset.top + contentInset.bottom)).isActive = true
        }
    }
}
