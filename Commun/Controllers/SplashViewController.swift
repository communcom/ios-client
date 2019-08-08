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
    var errorView: UIView!
    
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
    
    func showErrorScreen() {
        // reset
        hideErrorView()
        
        // setup new errorView
        errorView = UIView(frame: self.view.frame)
        errorView.backgroundColor = .white
        self.view.addSubview(errorView)
        self.view.bringSubviewToFront(errorView)
        
        // label
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "there is an error occurred".localized().uppercaseFirst + "\n" + "tap to try again".localized().uppercaseFirst
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(label)
        
        // constraint for label
        label.centerXAnchor.constraint(equalTo: errorView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: errorView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16).isActive = true
        
        // action for label
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(retryDidTouch))
        label.addGestureRecognizer(tap)
    }
    
    @objc func retryDidTouch(_ tap: UITapGestureRecognizer) {
        hideErrorView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            AppDelegate.reloadSubject.onNext(true)
        }
    }
    
    func hideErrorView() {
        errorView?.removeFromSuperview()
    }
}
