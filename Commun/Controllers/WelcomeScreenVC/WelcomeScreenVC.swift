//
//  WelcomeScreenVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 25/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class WelcomeScreenVC: UIPageViewController {
    // MARK: - Properties
    var currentPage = 0
    var pageControl: PillPageControl?

    fileprivate lazy var pages: [UIViewController] = {
        return  [
                    self.getItemWithIndex(0),
                    self.getItemWithIndex(1),
                    self.getItemWithIndex(2),
                ]
    }() as! [UIViewController]
    
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        self.dataSource = self
        self.delegate = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        pageControl = PillPageControl(frame: CGRect(x: 8, y: 35, width: UIScreen.main.bounds.size.width - 16, height: 25))
        pageControl?.pageCount = 3
        pageControl?.activeTint = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
        pageControl?.inactiveTint = #colorLiteral(red: 0.8980392157, green: 0.9058823529, blue: 0.9294117647, alpha: 1)
        
        self.view.addSubview(pageControl!)
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        UserDefaults.standard.set(true, forKey: "FirstStart")
    }

    func getItemWithIndex(_ index: Int) -> UIViewController? {
        switch index {
        case 0:
            let first = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
            first.item = 0
            return first
        
        case 1:
            let second = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
            second.item = 1
            return second
        
        case 2:
            let thrid = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
            thrid.item = 2
            return thrid
        
        default:
            return nil
        }
    }
}


// MARK: - UIPageViewControllerDataSource
extension WelcomeScreenVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 { return nil }
        guard previousIndex >= 0 else { return pages.last }
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex > 2 { return nil }
        guard nextIndex < pages.count else { return pages.first }
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
}


// MARK: - UIPageViewControllerDelegate
extension WelcomeScreenVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = viewControllers?.first {
             let viewControllerIndex = pages.firstIndex(of: vc)
            pageControl?.progress = CGFloat(viewControllerIndex ?? 0)
        }
    }
}
