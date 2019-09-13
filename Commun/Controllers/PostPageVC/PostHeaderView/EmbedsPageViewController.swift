//
//  Carousel.swift
//  Commun
//
//  Created by Chung Tran on 9/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class EmbedsPageViewController: UIPageViewController {
    private var orderedViewControllers: [UIViewController]? {
        didSet {
            guard let controllers = orderedViewControllers,
                controllers.count > 0
            else {return}
            setViewControllers([controllers.first!], direction: .forward, animated: true, completion: nil)
        }
    }
    
    var views: [UIView]? {
        didSet {
            guard let views = views else {return}
            let controllers = views.map {view -> UIViewController in
                let vc = UIViewController()
                vc.view = view
                return vc
            }
            orderedViewControllers = controllers
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
    }
}

extension EmbedsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers?.firstIndex(of: viewController)
            else {return nil}
        let previousIndex = index - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard orderedViewControllers!.count > previousIndex else {return nil}
        return orderedViewControllers![previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers?.firstIndex(of: viewController)
            else {return nil}
        let nextIndex = index + 1
        
        guard orderedViewControllers!.count != nextIndex else {return nil}
        
        guard orderedViewControllers!.count > nextIndex else {return nil}
        
        return orderedViewControllers![nextIndex]
    }
}
