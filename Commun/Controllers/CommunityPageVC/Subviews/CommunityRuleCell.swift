//
//  CommunityRuleCell.swift
//  Commun
//
//  Created by Chung Tran on 10/31/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class CommunityRuleCell: CommunityPageCell {
    // MARK: - Properties
    var rowIndex: Int?
    var expanded = false
    var rule: ResponseAPIContentGetCommunityRule?
    var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var containerView = UIView(backgroundColor: .white, cornerRadius: 10)
    lazy var titleLabel = UILabel.with(text: "2. Content should be Safe for Work", textSize: 15.0, weight: .bold, numberOfLines: 0)
    lazy var contentLabel = UILabel.with(text: "All content (title, articles, video, image, website, etc.) must be SFW: Safe For Work. Content that is NSFW: Not Safe For Work, is banned. This rule applies to all posts and comments.", textSize: 15.0, numberOfLines: 0)
    lazy var expandButton = UIButton.circleGray(imageName: "rule_expand")
    
    override func setUpViews() {
        super.setUpViews()
        // background color
        contentView.backgroundColor = #colorLiteral(red: 0.9599978328, green: 0.966491878, blue: 0.9829974771, alpha: 1)
        
        contentView.addSubview(containerView)
        containerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 10.0, right: 10.0))
        
        containerView.addSubview(titleLabel)
        titleLabel.autoPinTopAndLeadingToSuperView(inset: 20, xInset: 16)
        
        containerView.addSubview(expandButton)
        expandButton.autoPinTopAndTrailingToSuperView(inset: 20.0, xInset: 16)
        expandButton.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 8.0)
        expandButton.addTarget(self, action: #selector(expandButtonDidTouch(_:)), for: .touchUpInside)
    }
    
    func setUp(with newRule: ResponseAPIContentGetCommunityRule?) {
        rule = newRule
        titleLabel.text = "\((rowIndex ?? 0) + 1). " + (rule?.title ?? "")
        expandButton.isHidden = (newRule?.text == nil) || (newRule?.text?.isEmpty ?? false)
        setExpanded()
    }
    
    func setExpanded() {
        guard let rule = rule else {return}
        
        bottomConstraint?.isActive = false
        contentLabel.removeFromSuperview()
        
        if expanded {
            contentLabel.text = rule.text
            expandButton.setImage(UIImage(named: "rule_collapse"), for: .normal)
            
            // add contentLabel
            containerView.addSubview(contentLabel)
            contentLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 14)
            contentLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            contentLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            bottomConstraint = contentLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        } else {
            contentLabel.text = nil
            expandButton.setImage(UIImage(named: "rule_expand"), for: .normal)
            
            // pin bottom
            bottomConstraint = titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
        }
    }
    
    @objc func expandButtonDidTouch(_ sender: UIButton) {
        expanded = !expanded
        setExpanded()
        tableView?.beginUpdates()
        tableView?.endUpdates()
    }
}
