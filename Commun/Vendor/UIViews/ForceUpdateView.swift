//
//  ForceUpdateView.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ForceUpdateView: ErrorView {
    init() {
        super.init(retryAction: nil)
        defer {
            retryAction = {
                let url = URL(string: "itms-apps://itunes.apple.com/app/id\(Config.appStoreId)")!
                UIApplication.shared.open(url)
                // show app on appstore
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = #colorLiteral(red: 0.4485301971, green: 0.529779315, blue: 0.9566615224, alpha: 1)
    }
    
    override func layoutImageView() {
        imageView.image = UIImage(named: "update-the-app")
        
        imageView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 10 * Config.heightRatio)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        imageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 210/448)
            .isActive = true
    }
    
    override func layoutTitle() {
        title.textColor = .white
        title.text = "update the app".localized().uppercaseFirst
        title.textAlignment = .center
        title.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: -60 * Config.heightRatio)
        title.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        title.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    override func layoutSubtitle() {
        subtitle.textColor = .white
        subtitle.font = .systemFont(ofSize: 15)
        subtitle.text = "this version of the application is out of date.\nPlease update to continue using the app.".localized().uppercaseFirst
        subtitle.autoPinEdge(.top, to: .bottom, of: title, withOffset: 16 * Config.heightRatio)
        subtitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        subtitle.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
    
    override func layoutButton() {
        retryButton.setTitle("update".localized().uppercaseFirst, for: .normal)
        retryButton.setTitleColor(.appMainColor, for: .normal)
        retryButton.backgroundColor = .white
        retryButton.autoPinEdge(.top, to: .bottom, of: subtitle, withOffset: 40 * Config.heightRatio)
        retryButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 30 * Config.heightRatio)
        retryButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 30 * Config.heightRatio)
        retryButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 16 * Config.heightRatio)
    }
}
