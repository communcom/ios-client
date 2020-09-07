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
        guard let containerView = containerView,
            let presentedView = presentedView else { return .zero }
        
        // Make sure to account for the safe area insets
        let safeAreaFrame = containerView.bounds
            .inset(by: containerView.safeAreaInsets)
        
        let targetWidth = safeAreaFrame.width
        let fittingSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        var targetHeight = presentedView.systemLayoutSizeFitting(
            fittingSize, withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow).height
        
        if let scrollView = presentedView.subviews.first(where: {$0 is ContentHuggingScrollView}) as? ContentHuggingScrollView
        {
            targetHeight = scrollView.contentView.systemLayoutSizeFitting(
                fittingSize, withHorizontalFittingPriority: .required,
                verticalFittingPriority: .defaultLow).height
        }
        
        var frame = safeAreaFrame
        
        if targetHeight > frame.size.height {
            return frame
        }
        
        frame.origin.y += frame.size.height - targetHeight
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        return frame
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.roundCorners([.topLeft, .topRight], radius: 20)
    }
}
