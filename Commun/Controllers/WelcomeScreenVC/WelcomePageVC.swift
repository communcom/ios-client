//
//  WelcomePageVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
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
    
    // Timer
    let timeOut = 7
    var timer: Timer?
    var countDown: Timer?
    
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

        self.dataSource = self
        self.delegate = self
        
        // kick off pageController
        setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.countDown?.invalidate()
        self.timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
//        self.setUpCountDown()
    }
        
    
    // MARK: - Custom Functions
    func setUpCountDown() {
        // Timer reset
        var timeLeft = 7

        self.countDown?.invalidate()
        
        // Count down
        self.countDown = Timer(timeInterval: TimeInterval(1), repeats: true, block: { [weak self] (_) in
            guard let strongSelf = self else {return}
            
            timeLeft -= 1
            print(timeLeft)
            
            if timeLeft == 3 {
                if let timer = strongSelf.timer {
                    if !timer.isValid {
                        strongSelf.schedule()
                    }
                } else {
                    strongSelf.schedule()
                }
            }
            
            if timeLeft == 0 {
                timeLeft = 7
            }
        })
        
        RunLoop.current.add(countDown!, forMode: .common)
    }
    
    func schedule() {
        self.timer?.invalidate()

        // Re-schedule
        self.timer = Timer(timeInterval: TimeInterval(3), repeats: true, block: { [weak self] (_) in
            guard let strongSelf = self else { return }
            var newValue = strongSelf.currentPage
            if newValue == strongSelf.pages.count - 1 { newValue = 0 }
            else { newValue += 1 }
            
            strongSelf.currentPage = newValue
            strongSelf.showActionButtons(newValue)
        })
        
        RunLoop.current.add(timer!, forMode: .common)
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


// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
extension WelcomePageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC, vc.item > 0 else { return pages[pages.count - 1] }
        
        let previousIndex = vc.item - 1
        
        if previousIndex < 0 { return nil }
        guard previousIndex >= 0 else { return pages.last }
        guard pages.count > previousIndex else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC, vc.item < totalPages - 1 else {
            return pages[0]
        }
        
        let nextIndex = vc.item + 1
        
        if nextIndex > 3 {
            return nil
        }
        
        guard nextIndex < pages.count else { return pages.first }
        guard pages.count > nextIndex else { return nil }
                
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = viewControllers?.first as? WelcomeItemVC {
            let viewControllerIndex = vc.item
            
            self.showActionButtons(viewControllerIndex)
            self.currentPage = viewControllerIndex
//            self.timer?.invalidate()
//            self.setUpCountDown()
        }
    }
}
