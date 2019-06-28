//
//  MainViewController.swift
//  Commun
//
//  Created by Chung Tran on 27/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var splashImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let zoomAnim = CABasicAnimation(keyPath: "transform.scale")
        zoomAnim.fromValue = 1
        zoomAnim.toValue = 1.2
        zoomAnim.duration = 0.8
        zoomAnim.repeatCount = .infinity
        zoomAnim.autoreverses = true
        splashImageView.layer.add(zoomAnim, forKey: "Loading")
        // Do any additional setup after loading the view.
    }
    
    func animateSplash(_ completion: @escaping ()->Void) {
        splashImageView.layer.removeAnimation(forKey: "Loading")
        UIView.animate(withDuration: 0.3, animations: {
            self.splashImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.splashImageView.transform = CGAffineTransform(scaleX: 30, y: 30)
            }, completion: { _ in
                completion()
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
