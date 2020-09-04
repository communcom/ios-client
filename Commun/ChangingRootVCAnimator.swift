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
        
        if let toVC = toVC as? SplashVC,
            let toView = toVC.view.snapshotView(afterScreenUpdates: true),
            let slashImageSnapshotView = toVC.slashImageView.snapshotView(afterScreenUpdates: true)
        {
            fromVC.view.insertSubview(toView, at: 0)
            toView.transform = CGAffineTransform(scaleX: 30, y: 30)
            
            let maskLayer = slashImageSnapshotView.layer
            maskLayer.position = toVC.slashImageView.layer.position
            maskLayer.transform = CATransform3DMakeScale(30, 30, 1)
            fromVC.view.layer.mask = maskLayer
            
            // animate maskLayer
            UIView.animate(withDuration: 0.3, animations: {
                toView.transform = .identity
                maskLayer.transform = CATransform3DIdentity
            }) { (_) in
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
                self.fromVC = nil
                self.toVC = nil
            }
            return
        }
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let vc = toVC else {return}
        vc.view.layer.mask = nil
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
        
        fromVC = nil
        toVC = nil
    }
}
