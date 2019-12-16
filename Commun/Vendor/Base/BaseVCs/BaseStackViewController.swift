//
//  BaseStackViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class BaseVerticalStackViewController: BaseViewController {
    // MARK: - NestedType
    struct Action {
        var title: String
        var icon: UIImage?
        var tintColor: UIColor = .black
        var marginTop: CGFloat = 0
        var isActive: Bool = false
        var isSelected: Bool = false
        class TapGesture: UITapGestureRecognizer {
            var action: Action?
        }
    }
    
    // MARK: - Subviews
    lazy var scrollView = ContentHuggingScrollView(forAutoLayout: ())
    lazy var stackView = UIStackView(axis: .vertical, spacing: 2)
    
    // MARK: - Properties
    var actions: [Action]
    
    // MARK: - Initializers
    init(actions: [Action]) {
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .f3f5fa
        
        // scrollView
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        
        // stackView
        setUpStackView()
        scrollView.contentView.addSubview(stackView)
        layout()
    }

    func layout() {
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.layoutIfNeeded()
        stackView.arrangedSubviews.first?.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 10)
        stackView.arrangedSubviews.last?.roundCorners(UIRectCorner(arrayLiteral: .bottomLeft, .bottomRight), radius: 10)
    }
    
    func setUpStackView() {
        for action in actions {
            let actionView = viewForAction(action)
            stackView.addArrangedSubview(actionView)
            actionView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
                .isActive = true
            actionView.isUserInteractionEnabled = true
            let tap = Action.TapGesture(target: self, action: #selector(actionViewDidTouch(_:)))
            tap.action = action
            actionView.addGestureRecognizer(tap)
        }
    }
    
    func viewForAction(_ action: Action) -> UIView {
        let actionView = UIView(height: 65, backgroundColor: .white)
        let imageView = UIImageView(width: 35, height: 35)
        imageView.image = action.icon
        actionView.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let label = UILabel.with(text: action.title, textSize: 17)
        actionView.addSubview(label)
        label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let button = UIButton.circleGray(imageName: "next-arrow")
        button.isUserInteractionEnabled = false
        actionView.addSubview(button)
        button.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        button.autoAlignAxis(toSuperviewAxis: .horizontal)
        button.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 10)
        
        return actionView
    }
    
    func viewForActionAtIndex(_ index: Int) -> UIView? {
        return stackView.arrangedSubviews[safe: index]
    }
    
    @objc private func actionViewDidTouch(_ tap: Action.TapGesture) {
        guard let action = tap.action else {return}
        didSelectAction(action)
    }
    
    func didSelectAction(_ action: Action) {
        // for overriding
    }
}
