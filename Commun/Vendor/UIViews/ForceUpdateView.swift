//
//  ForceUpdateView.swift
//  Commun
//
//  Created by Chung Tran on 12/3/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class ForceUpdateView: ErrorView {
    init() {
        super.init(
        imageRatio: 332/560,
        imageNamed: "update-the-app",
        title: "update the app".localized().uppercaseFirst,
        subtitle: "this version of the application is out of".localized().uppercaseFirst,
        retryButtonTitle: "update".localized().uppercaseFirst) {
            let url = URL(string: "itms-apps://itunes.apple.com/app/id\(Config.appStoreId)")!
            UIApplication.shared.open(url)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .appMainColor
        title.textColor = .appWhiteColor
        
        subtitle.textColor = .appWhiteColor
        subtitle.font = .systemFont(ofSize: 15 * Config.heightRatio)
        
        retryButton.setTitleColor(.appMainColor, for: .normal)
        retryButton.backgroundColor = .appWhiteColor
    }
    
    override func layoutTitle() {
        title.textAlignment = .center
        title.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: -60 * Config.heightRatio)
        title.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        title.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
}
