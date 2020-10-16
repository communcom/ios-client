//
//  ChangingRootVCAnimator.swift
//  Commun
//
//  Created by Chung Tran on 9/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ChangingRootVCAnimator: NSObject {
    
    private override init() {}
    static var shared = ChangingRootVCAnimator()
    
    func changeRootVC(to toVC: UIViewController, from fromVC: UIViewController?) {
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
            UIView.animate(withDuration: 0.3, animations: {
                maskLayer.transform = CATransform3DScale(maskLayer.transform, 30, 30, 1)
            }) { (_) in
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
            }
            
            return
        }
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = toVC
    }
}
