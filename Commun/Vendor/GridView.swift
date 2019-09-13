//
//  GridView.swift
//  Commun
//
//  Created by Chung Tran on 9/10/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

class GridView: UIView {
    // MARK: - Properties
    var padding: CGFloat = 0.5
    var views = [UIView]()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
    }
    
    func setUp(views: [UIView]) {
        // Remove all subviews
        for view in subviews {
            view.removeFromSuperview()
        }
        
        // Resign views
        self.views = views
        
        // Get first 5 views
        var views = views.prefix(5)
        
        // setup views
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            addSubview(view)
        }
        
        // constraint for first and last
        views.first?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        views.first?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        views.last?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        views.last?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        // for 2 views
        if views.count == 2 {
            // height
            views.first?.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            views.last?.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            
            // width
            views.first?.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views.last?.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
        }
        
        // for 3 views
        if views.count == 3 {
            views.first?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            views.first?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            
            views[1].leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            views[1].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            views[1].heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views[1].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            
            views.last?.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views.last?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
        }
        
        // for 4 views
        if views.count == 4 {
            views.first?.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views.first?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            
            views[1].topAnchor.constraint(equalTo: topAnchor).isActive = true
            views[1].trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            views[1].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views[1].heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            
            views[2].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            views[2].leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            views[2].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views[2].heightAnchor.constraint(equalTo: heightAnchor
                , multiplier: 1/2, constant: -padding).isActive = true
            
            views.last?.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views.last?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
        }
        
        // for 5 views
        if views.count == 5 {
            views.first?.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views.first?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            
            views[1].topAnchor.constraint(equalTo: topAnchor).isActive = true
            views[1].trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            views[1].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views[1].heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            
            views[2].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            views[2].leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            views[2].heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views[2].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3, constant: -padding * 3 / 2).isActive = true
            
            views[3].centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            views[3].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            views[3].heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views[3].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3, constant: -padding * 3 / 2).isActive = true
            
            views.last?.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding).isActive = true
            views.last?.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3, constant: -padding * 3 / 2).isActive = true
            
            if self.views.count > 5 {
                let label = UILabel(frame: views.last!.frame)
                label.translatesAutoresizingMaskIntoConstraints = false
                addSubview(label)
                label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/3, constant: -padding * 3 / 2).isActive = true
                label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2, constant: -padding * 3 / 2).isActive = true
                
                label.backgroundColor = .black
                label.alpha = 0.5
                label.textColor = .white
                label.textAlignment = .center
                label.font = .boldSystemFont(ofSize: 20)
                label.text = "+\(self.views.count - 4)"
            }
        }
    }
    
    func setUp(images: [UIImage]) {
        let imageViews = images.map {UIImageView(image: $0)}
        setUp(views: imageViews)
    }
    
    func setUp(embeds: [ResponseAPIContentEmbedResult]) {
        let imageViews = embeds.compactMap { (embed) -> UIImageView? in
            let urlString = embed.thumbnail_url ?? embed.url
            guard let url = URL(string: urlString) else {return nil}
            let imageView = UIImageView(frame: .zero)
            imageView.sd_setImageCachedError(with: url, completion: nil)
            return imageView
        }
        setUp(views: imageViews)
    }
}
