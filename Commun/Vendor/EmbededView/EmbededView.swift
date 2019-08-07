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

class EmbededView: UIView, UIWebViewDelegate {
    var bag = DisposeBag()
    var heightConstraint: NSLayoutConstraint!
//    let didShowContentWithHeight = PublishSubject<CGFloat>()
    
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
    
    func setUpWithEmbeded(_ embededResult: ResponseAPIContentEmbedResult?){
        if embededResult?.type == "video",
            let html = embededResult?.html {
            showWebView(with: html)
        } else if embededResult?.type == "photo",
            let urlString = embededResult?.url,
            let url = URL(string: urlString) {
            if urlString.lowercased().ends(with: ".gif") {
                showWebView(with: "<div><div style=\"left: 0; width: 100%; height: 0; position: relative; padding-bottom: 74.9457%;\"><img src=\"\(urlString)\" /></div></div>")
            } else {
                showPhoto(with: url)
            }
        } else {
            adjustHeight(withHeight: 0)
        }
    }
    
    func showWebView(with htmlString: String) {
        var webView: HTMLStringWebView!
        
        if let currentWebView = subviews.first(where: {$0 is HTMLStringWebView}) as? HTMLStringWebView {
            webView = currentWebView
        } else {
            removeSubviews()
            webView = HTMLStringWebView()
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
            webView.delegate = self
        }
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func showPhoto(with url: URL) {
        removeSubviews()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.addTapToViewer()
        
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        imageView.showLoading()
        
        imageView.sd_setImage(with: url) { [weak self] (image, _, _, _) in
            guard let strongSelf = self else {return}
            var image = image
            if image == nil {
                image = UIImage(named: "image-not-found")
                imageView.image = image
            }
            strongSelf.adjustHeight(withHeight: strongSelf.size.width * image!.size.height / image!.size.height)
        }
    }
    
    private func adjustHeight(withHeight height: CGFloat) {
        self.heightConstraint.constant = height
        hideLoading()
        self.setNeedsLayout()
//        self.didShowContentWithHeight.onNext(height)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let height  = (UIScreen.main.bounds.width-16) * webView.contentHeight / webView.contentWidth
        adjustHeight(withHeight: height)
    }

}
