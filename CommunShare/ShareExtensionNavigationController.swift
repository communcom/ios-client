//
//  ShareExtensionNavigationController.swift
//  CommunShare
//
//  Created by Sergey Monastyrskiy on 30.01.2020.
//  Copyright © 2020 Sergey Monastyrskiy. All rights reserved.
//
//  https://stackoverflow.com/questions/47028285/is-it-possible-to-open-full-view-controller-in-share-extension-instead-of-popup
//

import UIKit

@objc(ShareExtensionNavigationController)
class ShareExtensionNavigationController: UINavigationController {
    // MARK: - Class Initialization
     init() {
        let testViewController: UIViewController = TestViewController(nibName: nil, bundle: nil)

        super.init(rootViewController: testViewController)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    
    // MARK: - Class Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = .white
        self.navigationBar.isTranslucent = false
        
        self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)

        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.transform = CGAffineTransform.identity
        })
    }
}
