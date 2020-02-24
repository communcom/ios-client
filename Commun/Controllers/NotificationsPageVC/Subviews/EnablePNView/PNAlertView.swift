//
//  EnablePNView.swift
//  Commun
//
//  Created by Chung Tran on 2/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class PNAlertView: MyView {
    // MARK: - Properties
    weak var delegate: PNAlertViewDelegate?
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        cornerRadius = 15
        
        let title = UILabel.with(text: "enable push notifications".localized().capitalized, textSize: 17, weight: .semibold, numberOfLines: 0)
        addSubview(title)
        title.autoPinTopAndLeadingToSuperView(inset: 16)
        
        let closeButton = UIButton.close()
        closeButton.addTarget(self, action: #selector(buttonCloseDidTouch), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        closeButton.autoAlignAxis(.horizontal, toSameAxisOf: title)
        closeButton.autoPinEdge(.leading, to: .trailing, of: title, withOffset: 10)
        
        let content = UILabel.with(text: "let us notify you about receiving rewards, replies, or upvotes! Stay tuned for the most important and pleasant activities on Commun".localized().uppercaseFirst, textSize: 15, textColor: .a5a7bd, numberOfLines: 0)
        addSubview(content)
        content.autoPinEdge(.top, to: .bottom, of: title, withOffset: 6)
        content.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        content.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let button = CommunButton.default(height: 35, label: "open iOS Settings".localized().uppercaseFirst, isHuggingContent: false)
        button.addTarget(self, action: #selector(buttonOpenSettingsDidTouch), for: .touchUpInside)
        addSubview(button)
        button.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
        button.autoPinEdge(.top, to: .bottom, of: content, withOffset: 16)
    }
    
    @objc func buttonCloseDidTouch() {
        delegate?.closeButtonDidTouch(enablePNView: self)
    }
    
    @objc func buttonOpenSettingsDidTouch() {
        delegate?.openIOSSettingsButtonDidTouch(enablePNView: self)
    }
}

class PNAlertTableHeaderView: MyTableHeaderView {
    
    var delegate: PNAlertViewDelegate? {
        get {
            pnAlertView.delegate
        }
        set {
            pnAlertView.delegate = newValue
        }
    }
    
    lazy var pnAlertView = PNAlertView(forAutoLayout: ())
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        pnAlertView.backgroundColor = .f3f5fa
        
        addSubview(pnAlertView)
        pnAlertView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
    }
}
