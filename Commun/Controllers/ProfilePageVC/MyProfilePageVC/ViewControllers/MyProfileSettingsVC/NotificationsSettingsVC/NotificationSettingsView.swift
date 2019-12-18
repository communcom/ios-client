//
//  NotificationSettingsView.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class NotificationSettingsView: MyView {
    lazy var imageView: UIImageView = UIImageView(width: 35, height: 35)
    lazy var label = UILabel.with(textSize: 17)
    lazy var switchButton = UISwitch()
    
    override func commonInit() {
        super.commonInit()
        addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        addSubview(label)
        label.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        addSubview(switchButton)
        switchButton.onTintColor = .appMainColor
        switchButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        switchButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        switchButton.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 10)
    }
    
    func setUp(with action: NotificationsSettingsVC.Action) {
        imageView.image = action.icon
        label.text = action.title
        switchButton.isOn = action.isActive
    }
}
