//
//  WelcomeScreenVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 25/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class WelcomeScreenVC: UIPageViewController {

    var currentPage = 0
    var pageControl: PillPageControl?
    
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getItemWithIndex(0),
            self.getItemWithIndex(1),
            self.getItemWithIndex(2),
        ]
        }() as! [UIViewController]
    
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
        
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        UserDefaults.standard.set(true, forKey: "FirstStart")
    }

    func getItemWithIndex(_ index: Int) -> UIViewController? {
        switch index {
        case 0:
            let first = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
            first.image = UIImage(named: "Mask Group")
//            first.text = "Hundreds of thematic communities"
            let attributedString = NSMutableAttributedString(string: "Hundreds\nof thematic communities\n")
            let attributes1: [NSAttributedString.Key : Any] = [
                .foregroundColor: #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
            ]
            attributedString.addAttributes(attributes1, range: NSRange(location: 9, length: 23))
            first.attrString = attributedString
            first.view.tag = 0
            first.delegate = self
            return first
        case 1:
            let second = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
            second.image = UIImage(named: "Mask Group-2")
            second.text = "Subscribe to your favorite communities"
            second.view.tag = 1
            second.delegate = self
            return second
        case 2:
            let thrid = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
            thrid.image = UIImage(named: "Mask Group-3")
            thrid.text = "Read! upvote! comment!"
            thrid.view.tag = 2
            thrid.delegate = self
            return thrid
        default:
            return nil
        }
    }
}


extension WelcomeScreenVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 {
            return nil
        }
        
        guard previousIndex >= 0          else { return pages.last }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex > 2 {
            return nil
        }
        
        
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }

}

extension WelcomeScreenVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = viewControllers?.first {
             let viewControllerIndex = pages.index(of: vc)
            pageControl?.progress = CGFloat(viewControllerIndex ?? 0)
        }
    }
}

extension WelcomeScreenVC: WelcomeItemDelegate {
    
    func welcomeItemDidTapSignIn() {
        self.navigationController?.pushViewController(controllerContainer.resolve(SignInVC.self)!)
    }
    
    func welcomeItemDidTapSignUp() {
        self.navigationController?.pushViewController(controllerContainer.resolve(SignUpVC.self)!)
    }
    
}
