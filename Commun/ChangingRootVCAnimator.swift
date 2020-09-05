//
//  ChangingRootVCAnimator.swift
//  Commun
//
//  Created by Chung Tran on 9/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ChangingRootVCAnimator: NSObject, CAAnimationDelegate {
    weak var fromVC: UIViewController?
    weak var toVC: UIViewController?
    
    private override init() {}
    static var shared = ChangingRootVCAnimator()
    
    func changeRootVC(to toVC: UIViewController, from fromVC: UIViewController?) {
        self.fromVC = fromVC
        self.toVC = toVC
        
        guard let fromVC = fromVC else {
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
            return
        }
        
        // from SplashVC
        if let fromVC = fromVC as? SplashVC,
            let toView = toVC.view.snapshotView(afterScreenUpdates: true)
        {
            fromVC.view.addSubview(toView)
            toView.frame = fromVC.view.frame
            
            let maskLayer = fromVC.slashImageView.snapshotView(afterScreenUpdates: false)!.layer
            maskLayer.position = fromVC.slashImageView.layer.position
            toView.layer.mask = maskLayer
            
            // animate maskLayer
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.duration = 0.3
            animation.fromValue = 0.7
            animation.toValue = 30
            animation.delegate = self
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            maskLayer.add(animation, forKey: "scale")
            return
        }
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
        self.fromVC = nil
        self.toVC = nil
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
        fromVC = nil
        toVC = nil
    }
}
