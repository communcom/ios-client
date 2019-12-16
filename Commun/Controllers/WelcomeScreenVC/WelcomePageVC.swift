//
//  WelcomePageVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit

class WelcomePageVC: UIPageViewController {
    // MARK: - Properties
    var totalPages = 4
        
    var currentPage = 0 {
        didSet {
            if currentPage > self.pages.count - 1 || currentPage < 0 { return }
            setViewControllers([pages[currentPage]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    fileprivate lazy var pages: [UIViewController] = {
        var list = [UIViewController]()
        
        for i in 0..<self.totalPages {
            list.append(self.pageAtIndex(i))
        }
        
        return list
    }()
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure views
        self.view.backgroundColor = .white
        
        // kick off pageController
        setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
    }
    
    private func pageAtIndex(_ index: Int) -> UIViewController {
        let vc = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
        
        vc.item = index
        return vc
    }
    
    func showActionButtons(_ index: Int) {
        if let welcomeVC = self.parent as? WelcomeVC {
            welcomeVC.nextButton.isHidden           =   index == 3   // true
            welcomeVC.signUpButton.isHidden         =   index != 3   // false
            welcomeVC.topSignInButton.isHidden      =   index == 3   // true
            welcomeVC.bottomSignInButton.isHidden   =   index != 3   // false
            welcomeVC.pageControl.selectedIndex     =   index
        }
    }
}
