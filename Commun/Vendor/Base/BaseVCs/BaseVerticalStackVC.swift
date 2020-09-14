//
//  BaseVerticalStackVC.swift
//  Commun
//
//  Created by Chung Tran on 3/12/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class BaseVerticalStackVC: BaseViewController {
    // MARK: - Properties
    var padding: UIEdgeInsets {.zero}
    var stackViewPadding: UIEdgeInsets {UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)}
    var scrollViewTopConstraint: NSLayoutConstraint?
    var stackViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var stackView = UIStackView(axis: .vertical, spacing: 2, alignment: .fill, distribution: .fill)
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appLightGrayColor
        
        // scrollView
        viewWillSetUpScrollView()
        setUpScrollView()
        viewDidSetUpScrollView()
        
        // stackView
        viewWillSetUpStackView()
        setUpStackView()
        setUpArrangedSubviews()
        viewDidSetUpStackView()
    }
    
    func viewWillSetUpScrollView() {}
    
    func setUpScrollView() {
        view.addSubview(scrollView)
        scrollViewTopConstraint = scrollView.autoPinEdge(toSuperviewEdge: .top, withInset: padding.top)
        scrollView.autoPinEdge(toSuperviewEdge: .leading, withInset: padding.left)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing, withInset: padding.right)
        scrollView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: padding.bottom)
    }
    
    func viewDidSetUpScrollView() {}
    
    func viewWillSetUpStackView() {}
    func setUpStackView() {
        scrollView.contentView.addSubview(stackView)
        stackViewTopConstraint = stackView.autoPinEdge(toSuperviewEdge: .top, withInset: stackViewPadding.top)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: stackViewPadding.left, bottom: stackViewPadding.bottom, right: stackViewPadding.right), excludingEdge: .top)
    }
    
    func setUpArrangedSubviews() {
        
    }
    
    func viewDidSetUpStackView() {}
}
