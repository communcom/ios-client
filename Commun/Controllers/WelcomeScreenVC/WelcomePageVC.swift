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
    var currentPage = 0
    var pageControl: PillPageControl?
    var totalPages = 3
    
    fileprivate lazy var pages: [UIViewController] = {
        var list = [UIViewController]()
        for i in 0..<self.totalPages {
            list.append(self.pageAtIndex(i))
        }
        return list
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure views
        self.view.backgroundColor = .white

        self.dataSource = self
        self.delegate = self
        
        // kick off pageController
        setViewControllers([pages.first!], direction: .forward, animated: true, completion: nil)
        
        // Configure pageControl
        pageControl = PillPageControl(frame: CGRect(x: 8, y: 35, width: UIScreen.main.bounds.size.width - 16, height: 25))
        
        // configure pageControl
        pageControl?.pageCount = totalPages
        pageControl?.activeTint = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        pageControl?.inactiveTint = #colorLiteral(red: 0.8980392157, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
        
        self.view.addSubview(pageControl!)
        
        var i = 1
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.setViewControllers([self.pages[i%self.pages.count]], direction: .forward, animated: true, completion: nil)
            self.pageControl?.progress = CGFloat(i%self.pages.count)
            i += 1
        }
    }
    
    private func pageAtIndex(_ index: Int) -> UIViewController {
        let vc = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
        
        vc.item = index
        return vc
    }
}

// MARK: - Datasource, delegate
extension WelcomePageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC,
            vc.item > 0
        else {return nil}
        
        let previousIndex = vc.item - 1
        
        if previousIndex < 0 { return nil }
        guard previousIndex >= 0 else { return pages.last }
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? WelcomeItemVC,
            vc.item < totalPages - 1
        else {return nil}
        
        let nextIndex = vc.item + 1
        
        if nextIndex > 2 { return nil }
        guard nextIndex < pages.count else { return pages.first }
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = viewControllers?.first as? WelcomeItemVC {
             let viewControllerIndex = vc.item
            pageControl?.progress = CGFloat(viewControllerIndex)
        }
    }
}
