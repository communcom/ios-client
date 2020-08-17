//
//  ReportDetailView.swift
//  Commun
//
//  Created by Chung Tran on 8/17/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReportDetailView: MyView {
    // MARK: - Properties
    var report: ResponseAPIContentGetEntityReport?
    
    // MARK: - Subviews
    lazy var avatarImageView = MyAvatarImageView(size: 30)
    lazy var label = UILabel.with(textSize: 15, numberOfLines: 0)
    
    // MARK: - Initializer
    override func commonInit() {
        super.commonInit()
        cornerRadius = 10
        backgroundColor = UIColor(hexString: "#F9A468")!.inDarkMode(#colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1568627451, alpha: 1)).withAlphaComponent(0.1)
        let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .top, distribution: .fill)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        let leftView = UIView(width: 2, height: 15, backgroundColor: UIColor(hexString: "#F9A568")!).padding(UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
        
        stackView.addArrangedSubviews([leftView, avatarImageView, label])
    }
    
    func setUp(with report: ResponseAPIContentGetEntityReport) {
        avatarImageView.setAvatar(urlString: report.author.avatarUrl)
        
        label.attributedText = NSMutableAttributedString()
            .text(report.author.username ?? report.author.userId, weight: .bold)
            .text(" ")
            .text(report.reason)
    }
}
