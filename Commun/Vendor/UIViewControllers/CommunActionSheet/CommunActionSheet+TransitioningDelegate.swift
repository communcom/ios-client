//
//  CommunActionSheet+TransitioningDelegate.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunActionSheetPresentationController: DimmingPresentationController {
    var height: CGFloat
    
    init(height: CGFloat, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.height = height
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: height)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        //1
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)
        
        //2
        
        frame.origin.y = containerView!.frame.height - height - 16
        
        return frame
    }
}

extension CommunActionSheet: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CommunActionSheetPresentationController(height: height, presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
