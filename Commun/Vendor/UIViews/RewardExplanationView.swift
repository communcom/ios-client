//
//  PostRewardExplanationView.swift
//  Commun
//
//  Created by Chung Tran on 7/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class RewardExplanationView: MyView {
    let params: CMCardViewParameters
    
    lazy var swipeDownButton = UIView(width: 50, height: 5, backgroundColor: .appWhiteColor, cornerRadius: 2.5)
    lazy var showingOptionButton: UIStackView = {
        let view = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        let dropdownButton = UIButton.circleGray(imageName: "drop-down")
        let label = UILabel.with(text: "community points".localized().uppercaseFirst, textColor: .appGrayColor)
        view.addArrangedSubviews([label, dropdownButton])
        return view
    }()
    lazy var explanationView = UserNameRulesView(withFrame: CGRect(origin: .zero, size: CGSize(width: .adaptive(width: 355.0), height: .adaptive(height: 193.0))), andParameters: params)
    
    init(params: CMCardViewParameters) {
        self.params = params
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .clear
        explanationView.backgroundColor = .appWhiteColor
        explanationView.cornerRadius = 25
        
        let stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .center, distribution: .fill)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        let showInView = UIView(height: 50, backgroundColor: .appWhiteColor, cornerRadius: 25)
        let showInLabel = UILabel.with(text: "show in".localized().uppercaseFirst)
        showInView.addSubview(showInLabel)
        showInLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), excludingEdge: .trailing)
        showInView.addSubview(showingOptionButton)
        showingOptionButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20), excludingEdge: .leading)
        showInLabel.autoPinEdge(.trailing, to: .leading, of: showingOptionButton, withOffset: 10)
        
        stackView.addArrangedSubviews([swipeDownButton, showInView, explanationView])
        
        showInView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        explanationView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
}
