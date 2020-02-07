//
//  ReportOtherVC.swift
//  Commun
//
//  Created by Chung Tran on 2/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReportOtherVC: BaseViewController {
    // MARK: - Subviews
    lazy var closeButton = UIButton.close()
    lazy var textView = UITextView(forAutoLayout: ())
    lazy var sendButton = CommunButton.default(height: .adaptive(height: 50), label: "send".localized().uppercaseFirst, cornerRadius: .adaptive(height: 25), isHuggingContent: false, isDisableGrayColor: true)
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        title = "please enter a reason".localized().uppercaseFirst
        navigationItem.setHidesBackButton(true, animated: false)
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        view.addSubview(textView)
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.placeholder = "describe the problem".localized().uppercaseFirst + "..."
        textView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .bottom)
        
        view.addSubview(sendButton)
        sendButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        sendButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        sendButton.autoPinEdge(.top, to: .bottom, of: textView, withOffset: 10)
        sendButton.autoPinBottomToSuperViewSafeAreaAvoidKeyboard(inset: 10)
    }
}
