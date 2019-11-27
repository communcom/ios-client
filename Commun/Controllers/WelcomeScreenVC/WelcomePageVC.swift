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
    var pillPageControl: PillPageControl?
        
    var currentPage = 0 {
        didSet {
            if currentPage > self.pages.count - 1 || currentPage < 0 { return }
            setViewControllers([pages[currentPage]], direction: .forward, animated: true, completion: nil)
            pillPageControl?.progress = CGFloat(currentPage)
        }
    }
    
    // Timer
    let timeOut = 7
    var timer: Timer?
    var countdown: Timer?
    
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
        
        // Configure pageControl
        pillPageControl = PillPageControl(frame: CGRect(x: 8, y: 35, width: UIScreen.main.bounds.size.width - 16, height: 25))
        
        // configure pageControl
        pillPageControl?.pageCount = totalPages
        pillPageControl?.activeTint = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        pillPageControl?.inactiveTint = #colorLiteral(red: 0.8980392157, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
        
        self.view.addSubview(pillPageControl!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdown?.invalidate()
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpCountdown()
    }
        
    
    // MARK: - Custom Functions
    func setUpCountdown() {
        // Timer reset
        var timeLeft = 7
        countdown?.invalidate()
        
        // Count down
        countdown = Timer(timeInterval: TimeInterval(1), repeats: true, block: { [weak self] (_) in
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
        
        RunLoop.current.add(countdown!, forMode: .common)
    }
    
    func schedule() {
        timer?.invalidate()
        
        // Re-schedule
        timer = Timer(timeInterval: TimeInterval(3), repeats: true, block: { [weak self] (_) in
            guard let strongSelf = self else {return}
            var newValue = strongSelf.currentPage
            if newValue == strongSelf.pages.count - 1 {newValue = 0}
            else {newValue += 1}
            strongSelf.currentPage = newValue
            
            if let welcomeVC = strongSelf.parent as? WelcomeVC {
                welcomeVC.nextButton.isHidden           =   newValue == 3   // true
                welcomeVC.signUpButton.isHidden         =   newValue != 3   // false
                welcomeVC.topSignInButton.isHidden      =   newValue == 3   // true
                welcomeVC.bottomSignInButton.isHidden   =   newValue != 3   // false
            }
        })
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func pageAtIndex(_ index: Int) -> UIViewController {
        let vc = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
        
        vc.item = index
        return vc
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
        guard let vc = viewController as? WelcomeItemVC, vc.item < totalPages - 1 else { return pages[0] }
        
        let nextIndex = vc.item + 1
        
        if nextIndex > 2 { return nil }
        
        guard nextIndex < pages.count else { return pages.first }
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = viewControllers?.first as? WelcomeItemVC {
            let viewControllerIndex = vc.item
            
            currentPage = viewControllerIndex
            timer?.invalidate()
            setUpCountdown()
        }
    }
}
