//
//  BasicPostCell.swift
//  Commun
//
//  Created by Chung Tran on 10/21/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

final class BasicPostCell: PostCell {
    // MARK: - Constants
    let embedViewDefaultHeight: CGFloat = 216.5
    
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var contentLabel   = UILabel.with(textSize: 14, numberOfLines: 0)
    lazy var gridViewContainerView = UIView(height: embedViewDefaultHeight)
    lazy var gridView       = GridView(forAutoLayout: ())
    
    // MARK: - Layout
    override func layoutContent() {
        contentView.addSubview(contentLabel)
        contentLabel.autoPinEdge(.top, to: .bottom, of: metaView, withOffset: 10)
        contentLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        contentLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)

        contentView.addSubview(gridViewContainerView)
        gridViewContainerView.autoPinEdge(toSuperviewEdge: .leading)
        gridViewContainerView.autoPinEdge(toSuperviewEdge: .trailing)
        gridViewContainerView.autoPinEdge(.top, to: .bottom, of: contentLabel, withOffset: 10)
        
        gridViewContainerView.addSubview(gridView)
        gridView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
        
        gridViewContainerView.autoPinEdge(.bottom, to: .top, of: voteActionsContainerView)
    }
    
    override func setUp(with post: ResponseAPIContentGetPost?) {
        super.setUp(with: post)
        self.accessibilityLabel = "PostCardCell"
        
        let defaultAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        
        if let content = post?.content,
            let firstSentence = content.first(where: {$0.type == "paragraph"})
        {
            let mutableAS = NSMutableAttributedString()
            var attributedText = firstSentence
                .toAttributedString(currentAttributes: defaultAttributes)
            if attributedText.length > 150 {
                attributedText = attributedText.attributedSubstring(from: NSMakeRange(0, 150))
                mutableAS.append(NSAttributedString(string: "...", attributes: defaultAttributes))
            }
            mutableAS.insert(attributedText, at: 0)

            // check last charters a space
            let spaceSymbols = "\n"
            let components = mutableAS.components(separatedBy: spaceSymbols)
            if let last = components.last, last.isEqual(to: NSAttributedString(string: "")) {
                mutableAS.deleteCharacters(in: NSRange(location: mutableAS.length - spaceSymbols.count, length: spaceSymbols.count))
            }

            contentLabel.attributedText = mutableAS
        }

        if let embeds = post?.attachments, !embeds.isEmpty
        {
            gridView.setUp(embeds: embeds)

            gridViewContainerView.heightConstraint?.constant = 31/40 * UIScreen.main.bounds.width
        }
        else {
            gridViewContainerView.heightConstraint?.constant = 0
        }
    }
}
