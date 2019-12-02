//
//  FTUECommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FTUECommunityCell: CommunityCollectionCell<ResponseAPIContentGetCommunity> {
    var shouldShowBonus = true
    
    override func joinButtonDidTouch() {
        // points
        if (community?.isSubscribed ?? false) == false && shouldShowBonus {
            let pointsView = UIView(height: 30, backgroundColor: .white, cornerRadius: 15)
            contentView.addSubview(pointsView)
            pointsView.autoAlignAxis(toSuperviewAxis: .vertical)
            pointsView.autoPinEdge(.bottom, to: .top, of: joinButton, withOffset: 16)
            
            let imageView = UIImageView(width: 24, height: 24)
            imageView.image = UIImage(named: "ftue-point")
            pointsView.addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 0), excludingEdge: .trailing)

            let pointsLabel = UILabel.with(text: "\(Config.appConfig?.ftueCommunityBonus ?? 10)" + " pts", textSize: 15, weight: .semibold, textColor: .appMainColor)
            pointsView.addSubview(pointsLabel)
            pointsLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 5)
            pointsLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
            pointsLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)

            // animation
            CATransaction.begin()
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.fromValue = 0
            fadeAnim.toValue = 1

            let moveUpAnim = CABasicAnimation(keyPath: "position.y")
            moveUpAnim.byValue = -16

            let groupAnim = CAAnimationGroup()
            groupAnim.duration = 0.5
            groupAnim.animations = [fadeAnim, moveUpAnim]
            groupAnim.fillMode = .forwards
            groupAnim.isRemovedOnCompletion = false

            CATransaction.setCompletionBlock {
                pointsView.removeFromSuperview()
                super.joinButtonDidTouch()
            }

            pointsView.layer.add(groupAnim, forKey: nil)

            CATransaction.commit()
        }
        else {
            super.joinButtonDidTouch()
        }
    }
}
