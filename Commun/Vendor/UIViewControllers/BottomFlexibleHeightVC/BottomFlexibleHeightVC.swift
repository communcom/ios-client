//
//  BottomFlexibleHeightVC.swift
//  Commun
//
//  Created by Chung Tran on 9/30/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import UIKit

class BottomFlexibleHeightPresentationController: FlexibleHeightPresentationController {
    override func calculateFittingHeightOfPresentedView(fittingSize: CGSize) -> CGFloat {
        let vc = presentedViewController as! BottomFlexibleHeightVC
        var height: CGFloat = 0
        
        // calculate header
        height += vc.headerStackViewEdgeInsets.top + vc.headerStackViewEdgeInsets.bottom
        
        let targetWidth = safeAreaFrame!.width
        let fittingSize = CGSize(
            width: targetWidth - vc.headerStackViewEdgeInsets.left - vc.headerStackViewEdgeInsets.right,
            height: UIView.layoutFittingCompressedSize.height
        )
        
        height += calculateFittingHeight(of: vc.headerStackView, fittingSize: fittingSize)
        
        height += vc.scrollView.contentView.systemLayoutSizeFitting(
            fittingSize, withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow).height

        return height
    }
}

class BottomFlexibleHeightVC: BaseViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

// MARK: - UIViewControllerTransitioningDelegate
extension BottomFlexibleHeightVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomFlexibleHeightPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class CMBottomSheet: BottomFlexibleHeightVC {
    var panGestureRecognizer: UIPanGestureRecognizer?
    var interactor: SwipeDownInteractor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor = SwipeDownInteractor()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
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
}

extension CMBottomSheet {
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
