//
//  CMActionSheet.swift
//  Commun
//
//  Created by Chung Tran on 8/12/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMActionSheet: SwipeDownDismissViewController {
    // MARK: - Nested type
    struct Action {
//        var title: String?
//        var icon: UIImage?
        var view: UIView
        var handle: (() -> Void)?
        var bottomMargin: CGFloat? = 0
    }
    
    // MARK: - Properties
    var backgroundColor: UIColor = .appLightGrayColor {
        didSet { view.backgroundColor = backgroundColor }
    }
    
    // MARK: - Subviews
    lazy var headerStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var closeButton = UIButton.close()
    var headerView: UIView {
        didSet { configureHeader() }
    }
    lazy var actionStackView = UIStackView(axis: .vertical, spacing: 0, alignment: .fill, distribution: .fill)
    var actions: [Action] {
        didSet { setUpActions() }
    }
    
    // MARK: - Initializer
    init(headerView: UIView?, title: String?, actions: [Action]) {
        self.actions = actions
        self.headerView = headerView ?? UILabel.with(text: title, textSize: 15, weight: .bold, textAlignment: .center)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // set up header
        view.addSubview(headerStackView)
        headerStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        headerStackView.autoSetDimension(.height, toSize: 44)
        
        configureHeader()
        
        // set up action
        view.addSubview(actionStackView)
        actionStackView.autoPinEdge(.top, to: .bottom, of: headerStackView, withOffset: 10)
        actionStackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 10)
        actionStackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        actionStackView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 16)
        
        actionStackView.cornerRadius = 10
        
        setUpActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for (index, action) in actions.enumerated() {
            if action.bottomMargin != nil {
                action.view.roundCorners([.bottomLeft, .bottomRight], radius: 10)
            }
            
            if let previousAction = actions[safe: index - 1], previousAction.bottomMargin != nil {
                action.view.roundCorners([.topLeft, .topRight], radius: 10)
            }
        }
    }
    
    private func configureHeader() {
        headerStackView.removeArrangedSubviews()
        headerStackView.addArrangedSubviews([headerView, closeButton])
    }
    
    private func setUpActions() {
        actionStackView.removeArrangedSubviews()
        let views = actions.map {$0.view}
        actionStackView.addArrangedSubviews(views)
        
        for action in actions {
            actionStackView.setCustomSpacing(action.bottomMargin ?? 2, after: action.view)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension CMActionSheet: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CMActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
