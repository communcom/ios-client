//
//  Carousel.swift
//  Commun
//
//  Created by Chung Tran on 9/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift

class EmbedViewController: UIViewController {
    var index: Int!
}

class EmbedsPageViewController: UIPageViewController {
//    weak var parentView: UIView?
//    private var heightConstraint: NSLayoutConstraint? {
//        return parentView?.constraints.first(where: {$0.firstAttribute == .height})
//    }
    
    // keep track of index
//    fileprivate var currentPageIndex: Int? {
//        didSet {
//            guard let index = currentPageIndex else {return}
//            setHeight(height: cachedHeight[index] ?? 300)
//        }
//    }
//    fileprivate var lastPendingViewControllerIndex: Int?
    
    // caching height
//    var cachedHeight = [Int: CGFloat]() {
//        didSet {
//            guard let index = currentPageIndex,
//                let height = cachedHeight[index]
//            else {return}
//            if heightConstraint?.constant != height {
//                setHeight(height: height)
//            }
//        }
//    }
    
    private let bag = DisposeBag()
    
    var embeds: [ResponseAPIContentEmbedResult]? {
        didSet {
            guard let embeds = embeds else {return}
            
            var views = [UIView]()
            
            for (_, embed) in embeds.enumerated() {
                if let html = embed.html {
                    let webView = HTMLStringWebView(frame: .zero)
                    webView.scrollView.isScrollEnabled = false
                    webView.scrollView.bouncesZoom = false
                    webView.scrollView.contentInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
                    webView.loadHTMLString(html, baseURL: nil)
//                    webView.rx.didFinishLoad
//                        .subscribe(onNext: {[weak self] in
//                            let height  = (UIScreen.main.bounds.width-16) * webView.contentHeight / webView.contentWidth
//                            self?.cachedHeight[index] = height
//                        })
//                        .disposed(by: bag)
                    views.append(webView)
                }
                else {
                    let imageView = UIImageView(frame: .zero)
                    imageView.backgroundColor = .black
                    imageView.contentMode = .scaleAspectFit
                    let urlString = embed.thumbnail_url ?? embed.url
                    guard let url = URL(string: urlString)
                        else {return}
                    imageView.sd_setImageCachedError(with: url) { (error, image) in
                        imageView.addTapToViewer()
//                        guard let strongSelf = self else {return}
//                        let height = strongSelf.view.size.width * imageView.image!.size.height / imageView.image!.size.width
//                        strongSelf.cachedHeight[index] = height
                    }
                    views.append(imageView)
                }
            }
            
            orderedViewControllers = views.map {view -> EmbedViewController in
                let vc = EmbedViewController()
                vc.view = view
                vc.index = views.firstIndex(of: view)
                return vc
            }
        }
    }
    
    private var orderedViewControllers: [EmbedViewController]? {
        didSet {
            guard let controllers = orderedViewControllers,
                controllers.count > 0
            else {return}
            setViewControllers([controllers.first!], direction: .forward, animated: true, completion: nil)
            
        }
    }
    
    private var prevButton: UIButton! {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.setImage(UIImage(named: "btn-prev"), for: .normal)
        return button
    }
    
    private var nextButton: UIButton! {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        button.setImage(UIImage(named: "btn-next"), for: .normal)
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    
        prevButton.addTarget(self, action: #selector(prevEmbed), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextEmbed), for: .touchUpInside)
    }
    
    @objc private func prevEmbed() {
        flipPage(direction: .reverse)
    }
    
    @objc private func nextEmbed() {
        flipPage(direction: .forward)
    }
    
    private func flipPage(direction: UIPageViewController.NavigationDirection) {
        guard let currentVC = viewControllers?.first as? EmbedViewController,
            var index = currentVC.index,
            index >= 0
            else {return}
        
        if direction == .forward {
            index += 1
        } else {
            index -= 1
        }
        
        guard index >= 0,
            orderedViewControllers!.count > index,
            let vc = orderedViewControllers?[index] else {return}
        setViewControllers([vc], direction: direction, animated: true, completion: nil)
    }
    
//    private func setHeight(height: CGFloat, animated: Bool = false) {
//        print(cachedHeight)
//        heightConstraint?.constant = height
////        UIView.animate(withDuration: 0.3) {
////            self.parentView?.layoutIfNeeded()
////        }
//    }
}

extension EmbedsPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? EmbedViewController)?.index
            else {return nil}
        let previousIndex = index - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard orderedViewControllers!.count > previousIndex else {return nil}
        return orderedViewControllers![previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? EmbedViewController)?.index
            else {return nil}
        let nextIndex = index + 1
        
        guard orderedViewControllers!.count != nextIndex else {return nil}
        
        guard orderedViewControllers!.count > nextIndex else {return nil}
        
        return orderedViewControllers![nextIndex]
    }
    
//    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        if pendingViewControllers.count > 0 {
//            let viewController = pendingViewControllers[0]
//            lastPendingViewControllerIndex = orderedViewControllers?.firstIndex(of: viewController)
//        }
//    }
    
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        if completed {
//            currentPageIndex = orderedViewControllers?.firstIndex(of: viewControllers!.first!)
//        }
//    }
}
