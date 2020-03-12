//
//  ReportsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class ReportVC: VerticalActionsVC {
    // MARK: - Subviews
    lazy var closeButton = UIButton.close()
    let sendButton = CommunButton.default(height: 50, label: "send".localized().uppercaseFirst, isDisabled: true)

    // MARK: - Properties
    var choosedReasons: [BlockchainManager.ReportReason] {
        actions.filter {$0.isSelected == true}
            .compactMap {BlockchainManager.ReportReason(rawValue: $0.title)}
    }
    
    var otherReason: String?
    
    // MARK: - Initializers
    init() {
        super.init(actions: BlockchainManager.ReportReason.allCases.map({ (reason) -> Action in
            Action(title: reason.rawValue, icon: nil)
        }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
    }
    
    override func setUp() {
        super.setUp()
        
        title = "please select a reason".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        
        let alertView = UIView(height: 62, backgroundColor: .white, cornerRadius: 10)
        scrollView.contentView.addSubview(alertView)
        alertView.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: 20)
        alertView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        alertView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        let imageView = UIImageView(width: 24, height: 24)
        imageView.image = UIImage.init(named: "reports-alert")
        alertView.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        let descriptionLabel = UILabel.with(text: "if someone is in immediate danger, call local emergency services. Don't wait.".localized().uppercaseFirst, textSize: 12, weight: .semibold, textColor: .a5a7bd, numberOfLines: 2)
        alertView.addSubview(descriptionLabel)
        descriptionLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 10)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        scrollView.contentView.addSubview(sendButton)
        sendButton.autoPinEdge(.top, to: .bottom, of: alertView, withOffset: 30)
        sendButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        sendButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        sendButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        sendButton.addTarget(self, action: #selector(sendButtonDidTouch), for: .touchUpInside)
    }
    
    override func setUpStackView() {
        scrollView.contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16), excludingEdge: .bottom)
    }
    
    override func viewForAction(_ action: VerticalActionsVC.Action) -> UIView {
        let actionView = ReportOptionView(height: 58, backgroundColor: .white)
        actionView.checkBox.isUserInteractionEnabled = false
        actionView.titleLabel.text = action.title
        actionView.checkBox.isSelected = action.isSelected
        
        return actionView
    }
    
    override func didSelectAction(_ action: Action) {
        guard let index = actions.firstIndex(where: { $0.title == action.title }) else { return }
        
        actions[index].isSelected = !actions[index].isSelected
        (viewForActionAtIndex(index) as! ReportOptionView).checkBox.isSelected = actions[index].isSelected
        
        sendButton.isDisabled = !actions.any(matching: { $0.isSelected == true })
        
        // other reason
        if index == actions.count - 1, actions[index].isSelected {
            // open vc for entering text
            let vc = ReportOtherVC()
            
            vc.completion = { otherReason in
                vc.back()
                self.otherReason = otherReason
                self.sendButtonDidTouch()
                self.sendButton.isDisabled = true
            }
            
            show(vc, sender: nil)
        }
    }
    
    func checkValues() -> Bool {
        guard !sendButton.isDisabled else {
            let sendButtonFrame = view.convert(sendButton.frame, from: scrollView.contentView)
            self.hintView?.display(inPosition: sendButtonFrame.origin, withType: .chooseProblem, completion: {})
            return false
        }
                        
        return true
    }
    
    // MARK: - Actions
    @objc func sendButtonDidTouch() {
    }
}
