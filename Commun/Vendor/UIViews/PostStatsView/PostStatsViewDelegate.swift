//
//  PostStatsViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 9/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol PostStatsViewDelegate: class {
    var post: ResponseAPIContentGetPost? {get}
    func postStatsViewDonationButtonDidTouch(_ postStatsView: PostStatsView)
    func postStatsViewDonatorsDidTouch(_ postStatsView: PostStatsView)
}

extension PostStatsViewDelegate {
    func postStatsViewDonationButtonDidTouch(_ postStatsView: PostStatsView) {
        var post = self.post
        post?.showDonationButtons = true
        post?.notifyChanged()
    }
    
    func postStatsViewDonatorsDidTouch(_ postStatsView: PostStatsView) {
        guard let viewController = (self as? UIViewController) ?? (self as? UIView)?.parentViewController
        else {return}
        
        guard let post = post else {return}
        
        let vc = PostRewardsVC(post: post)
        vc.modelSelected = {donation in
            vc.dismiss(animated: true) {
                viewController.showProfileWithUserId(donation.sender.userId)
            }
        }
        
        vc.donateButtonHandler = {
            vc.dismiss(animated: true) {
                self.postStatsViewDonationButtonDidTouch(postStatsView)
            }
        }
        
        vc.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc
        viewController.present(vc, animated: true, completion: nil)
    }
}
