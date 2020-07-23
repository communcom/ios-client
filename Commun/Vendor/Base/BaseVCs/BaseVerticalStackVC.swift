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
        scrollViewTopConstraint = scrollView.autoPinEdge(toSuperviewEdge: .top)
        scrollView.autoPinEdge(toSuperviewEdge: .leading)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing)
        scrollView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard()
    }
    
    func viewDidSetUpScrollView() {}
    
    func viewWillSetUpStackView() {}
    func setUpStackView() {
        scrollView.contentView.addSubview(stackView)
        stackViewTopConstraint = stackView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10), excludingEdge: .top)
    }
    
    func setUpArrangedSubviews() {
        fatalError("Must override")
    }
    
    func viewDidSetUpStackView() {}
}
