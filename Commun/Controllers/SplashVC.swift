//
//  MainViewController.swift
//  Commun
//
//  Created by Chung Tran on 27/06/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift

class SplashVC: BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {.lightContent}
    
    lazy var slashImageView = UIImageView(width: 60, height: 130.5, imageNamed: "slash")
    var errorView: UIView!
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .appMainColor
        
        view.addSubview(slashImageView)
        slashImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        slashImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let zoomAnim = CABasicAnimation(keyPath: "transform.scale")
        zoomAnim.fromValue = 1
        zoomAnim.toValue = 1.2
        zoomAnim.duration = 0.8
        zoomAnim.repeatCount = .infinity
        zoomAnim.autoreverses = true
        slashImageView.layer.add(zoomAnim, forKey: "Loading")
        // Do any additional setup after loading the view.
        
        AuthManager.shared.status
            .subscribe(onNext: { (status) in
                switch status {
                case .error(let error):
                    self.showErrorScreen(title: "error".localized().uppercaseFirst, subtitle: error.localizedDescription)
                default:
                    self.view.hideErrorView()
                }
            })
            .disposed(by: disposeBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if UserDefaults.appGroups.object(forKey: appShareExtensionKey) != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5)) {
                UIApplication.shared.open(URL(string: "commun://createPost")!)
            }
        }
    }
    
    func animateSplash(_ completion: @escaping () -> Void) {
        slashImageView.layer.removeAnimation(forKey: "Loading")
        UIView.animate(withDuration: 0.3, animations: {
            self.slashImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (_) in
            UIView.animate(withDuration: 0.3, animations: {
                self.slashImageView.transform = CGAffineTransform(scaleX: 30, y: 30)
            }, completion: { _ in
                completion()
            })
        }
    }
    
    func showErrorScreen(title: String? = nil, subtitle: String? = nil, retryButtonTitle: String? = nil)
    {
        view.showErrorView(title: title, subtitle: subtitle, retryButtonTitle: retryButtonTitle)
        { [weak self] in
            self?.reloadApp()
        }
    }
    
    @objc func retryDidTouch(_ tap: UITapGestureRecognizer) {
        reloadApp()
    }
    
    func reloadApp() {
        hideErrorView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            AuthManager.shared.reload()
        }
    }
    
    func hideErrorView() {
        view.hideErrorView()
    }
}
