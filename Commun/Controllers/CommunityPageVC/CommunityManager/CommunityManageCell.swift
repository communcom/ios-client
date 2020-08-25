//
//  File.swift
//  Commun
//
//  Created by Chung Tran on 8/14/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CommunityManageCell: MyTableViewCell {
    // MARK: - Subviews
    lazy var stackView = UIStackView(axis: .vertical, spacing: 16, alignment: .fill, distribution: .fill)
    lazy var mainView = UIView(forAutoLayout: ())
    lazy var bottomView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.addSubview(bottomStackView)
        bottomStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
        actionButton.addTarget(self, action: #selector(actionButtonDidTouch), for: .touchUpInside)
        bottomStackView.addArrangedSubviews([voteLabel, actionButton])
        return view
    }()
    lazy var bottomStackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
    lazy var actionButton = CommunButton.default()
    lazy var voteLabel = UILabel.with(textSize: 15, numberOfLines: 2)
    
    override func setUpViews() {
        super.setUpViews()
        backgroundColor = .appWhiteColor
        selectionStyle = .none
        
        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        setUpStackView()
    }
    
    func setUpStackView() {
        let spacer = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
        stackView.addArrangedSubviews([
            mainView,
            spacer,
            bottomView,
            UIView.spacer(height: 16, backgroundColor: .appLightGrayColor)
        ])
        
        stackView.setCustomSpacing(0, after: spacer)
        stackView.setCustomSpacing(0, after: bottomView)
    }
    
    @objc func actionButtonDidTouch() {
        
    }
    
    // MARK: - Helper
    @discardableResult
    func addViewToMainView<T: UIView>(type: T.Type, contentInsets: UIEdgeInsets = .zero) -> T {
        if !(mainView.subviews.first === T.self) {
            let view = T(forAutoLayout: ())
            mainView.removeSubviews()
            mainView.addSubview(view)
            view.autoPinEdgesToSuperviewEdges(with: contentInsets)
        }
        
        let view = mainView.subviews.first as! T
        return view
    }
}
