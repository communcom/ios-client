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
        
        #warning("remove later")
        if let title = post?.content.title,
            title != " "
        {
            self.contentLabel.text = title
        }
        else {
            // TODO: Parsing
            self.contentLabel.text = post?.content.body.full
        }
         
        if let embeds = post?.content.embeds.compactMap({$0.result}),
            !embeds.isEmpty
        {
            gridView.setUp(embeds: embeds)
            gridViewContainerView.heightConstraint?.constant = 31/40 * UIScreen.main.bounds.width
        }
        else {
            gridViewContainerView.heightConstraint?.constant = 0
        }
        
    }
}
