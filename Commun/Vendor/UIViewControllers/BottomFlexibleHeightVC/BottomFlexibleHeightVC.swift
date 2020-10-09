//
//  BottomFlexibleHeightVC.swift
//  Commun
//
//  Created by Chung Tran on 9/30/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import UIKit

class BottomFlexibleHeightVC: BaseViewController, UIViewControllerTransitioningDelegate {
    // MARK: - Nested type
    class PresentationController: FlexibleHeightPresentationController {
        override func calculateFittingHeightOfPresentedView(targetWidth: CGFloat) -> CGFloat {
            let vc = presentedViewController as! BottomFlexibleHeightVC
            return vc.fittingHeightInContainer(safeAreaFrame: safeAreaFrame!)
        }
    }
    
    func fittingHeightInContainer(safeAreaFrame: CGRect) -> CGFloat {
        var height: CGFloat = 0
        
        // calculate header
        height += headerStackViewEdgeInsets.top + headerStackViewEdgeInsets.bottom
        
        height += headerStackView.fittingHeight(targetWidth: safeAreaFrame.width - headerStackViewEdgeInsets.left - headerStackViewEdgeInsets.right)
        
        height += scrollView.contentView.fittingHeight(targetWidth: safeAreaFrame.width)

        return height
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var scrollView = ContentHuggingScrollView(scrollableAxis: .vertical)
    lazy var headerStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var closeButton: UIButton = {
        let button = UIButton.close(size: 30, backgroundColor: .appWhiteColor, tintColor: .appGrayColor)
        button.imageEdgeInsets = UIEdgeInsets(inset: 3)
        button.touchAreaEdgeInsets = UIEdgeInsets(inset: -7)
        button.addTarget(self, action: #selector(closeButtonDidTouch(_:)), for: .touchUpInside)
        return button
    }()
    
    var headerStackViewEdgeInsets: UIEdgeInsets { UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) }
    
    override func setUp() {
        super.setUp()
        // set up header
        headerStackView.addArrangedSubviews([.spacer(), closeButton])
        view.addSubview(headerStackView)
        headerStackView.autoPinEdgesToSuperviewEdges(with: headerStackViewEdgeInsets, excludingEdge: .bottom)
        
        view.addSubview(scrollView)
        scrollView.autoPinEdge(.top, to: .bottom, of: headerStackView, withOffset: headerStackViewEdgeInsets.bottom)
        scrollView.autoPinEdge(toSuperviewEdge: .leading)
        scrollView.autoPinEdge(toSuperviewEdge: .trailing)
        scrollView.autoPinBottomToSuperViewSafeAreaAvoidKeyboard()
    }
    
    @objc func closeButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class CMBottomSheet: BottomFlexibleHeightVC {
    var panGestureRecognizer: UIPanGestureRecognizer?
    var interactor: SwipeDownInteractor?
    
    var backgroundColor: UIColor = .appLightGrayColor {
        didSet { view.backgroundColor = backgroundColor }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor = SwipeDownInteractor()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
        
        view.backgroundColor = backgroundColor
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else {
            return
        }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.cancel()
        default:
            break
        }
    }
    
    func disableSwipeDownToDismiss() {
        guard let gesture = panGestureRecognizer else {return}
        view.removeGestureRecognizer(gesture)
    }
}

extension CMBottomSheet {
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
