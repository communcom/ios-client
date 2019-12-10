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
        super.init(
        imageRatio: 332/560,
        imageNamed: "update-the-app",
        title: "update the app".localized().uppercaseFirst,
        subtitle: "this version of the application is out of date.\nPlease update to continue using the app.".localized().uppercaseFirst,
        retryButtonTitle: "update".localized().uppercaseFirst)
        {
            let url = URL(string: "itms-apps://itunes.apple.com/app/id\(Config.appStoreId)")!
            UIApplication.shared.open(url)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = #colorLiteral(red: 0.4485301971, green: 0.529779315, blue: 0.9566615224, alpha: 1)
        title.textColor = .white
        
        subtitle.textColor = .white
        subtitle.font = .systemFont(ofSize: 15 * Config.heightRatio)
        
        retryButton.setTitleColor(.appMainColor, for: .normal)
        retryButton.backgroundColor = .white
    }
    
    override func layoutTitle() {
        title.textAlignment = .center
        title.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: -60 * Config.heightRatio)
        title.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        title.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
}
