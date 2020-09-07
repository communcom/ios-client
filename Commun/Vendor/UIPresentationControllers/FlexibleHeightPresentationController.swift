//
//  CMActionSheetPresentionController.swift
//  Commun
//
//  Created by Chung Tran on 4/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
class FlexibleHeightPresentationController: DimmingPresentationController {
    lazy var backingView = UIView(backgroundColor: .appLightGrayColor)
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {return}
        containerView.addSubview(backingView)
        backingView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        backingView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
            .isActive = true
        super.presentationTransitionWillBegin()
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        backingView.isHidden = true
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let safeAreaFrame = safeAreaFrame else { return .zero }
        
        let targetWidth = safeAreaFrame.width
        let fittingSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        let targetHeight = calculateFittingHeightOfPresentedView(fittingSize: fittingSize)
        
        var frame = safeAreaFrame
        
        if targetHeight > frame.size.height {
            return frame
        }
        
        frame.origin.y += frame.size.height - targetHeight
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        return frame
    }
    
    var safeAreaFrame: CGRect? {
        guard let containerView = containerView else { return nil }
        return containerView.bounds.inset(by: containerView.safeAreaInsets)
    }
    
    func calculateFittingHeightOfPresentedView(fittingSize: CGSize) -> CGFloat {
        calculateFittingHeight(of: presentedView!, fittingSize: fittingSize)
    }
    
    final func calculateFittingHeight(of view: UIView, fittingSize: CGSize) -> CGFloat {
        view.systemLayoutSizeFitting(
            fittingSize, withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow).height
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.roundCorners([.topLeft, .topRight], radius: 20)
    }
}
