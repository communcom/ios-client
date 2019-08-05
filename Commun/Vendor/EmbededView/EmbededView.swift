//
//  EmbededView.swift
//  Commun
//
//  Created by Chung Tran on 17/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift

class EmbededView: UIView {
    var bag = DisposeBag()
    var heightConstraint: NSLayoutConstraint!
    let didShowContentWithHeight = PublishSubject<CGFloat>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // assign height constraint
        self.heightConstraint = self.constraints.first {$0.firstAttribute == .height}
    }
    
    func setUpWithEmbeded(_ embeded: ResponseAPIContentEmbed?){
        if embeded?.result?.type == "video",
            let html = embeded?.result?.html {
            showWebView(with: html)
            return
        } else if embeded?.result?.type == "photo",
            let urlString = embeded?.result?.url,
            let url = URL(string: urlString) {
            showPhoto(with: url)
            return
        }
        
        // hide embeded
        self.adjustHeight(withHeight: 0)
    }
    
    private func showWebView(with htmlString: String) {
        // clean content
        removeSubviews()
        
        // create webView
        let webView = UIWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(webView)
        webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        webView.scrollView.contentInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bouncesZoom = false
        
        showLoading()
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        webView.rx.didFinishLoad
            .subscribe(onNext: {
                self.hideLoading()
                
                // modify height base on content
                var height: CGFloat = 383
                let str = webView.stringByEvaluatingJavaScript(from: "document.body.offsetHeight;") ?? "383"
                if let n = NumberFormatter().number(from: str) {
                    height = CGFloat(truncating: n)
                }
                self.adjustHeight(withHeight: height)
            })
            .disposed(by: bag)
    }
    
    private func showPhoto(with url: URL) {
        // clean content
        removeSubviews()
        
        // create imageView
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        showLoading()
        
        imageView.sd_setImage(with: url) { (image, _, _, _) in
            self.hideLoading()
            if image != nil {
                self.adjustHeight(withHeight: UIScreen.main.bounds.width*275/383)
            }
        }
    }
    
    private func adjustHeight(withHeight height: CGFloat) {
        print(height)
        self.didShowContentWithHeight.onNext(height)
        self.heightConstraint.constant = height
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    }

}
