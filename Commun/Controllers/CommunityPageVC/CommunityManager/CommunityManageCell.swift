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
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        let button = CommunButton.default(label: "accept".localized().uppercaseFirst)
        button.addTarget(self, action: #selector(actionButtonDidTouch), for: .touchUpInside)
        stackView.addArrangedSubviews([voteLabel, button])
        return view
    }()
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
    func setMessage(item: ResponseAPIContentGetProposal?) -> CMPostView {
        let postView = addViewToMainView(type: CMPostView.self)
        
        if let post = item?.post {
            postView.setUp(post: post)
        } else if let comment = item?.comment {
            postView.setUp(comment: comment)
        } else {
            let label = UILabel.with(text: "\(item?.postLoadingError != nil ? "Error: \(item!.postLoadingError!)" : "loading".localized().uppercaseFirst + "...")", textSize: 15, weight: .semibold, numberOfLines: 0)
            mainView.removeSubviews()
            mainView.addSubview(label)
            label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: 32, vertical: 0))
        }
        return postView
    }
    
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
