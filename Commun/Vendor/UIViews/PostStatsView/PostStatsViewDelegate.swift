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
        guard let vc = (self as? BaseViewController) ?? (self as? UIView)?.parentViewController,
            let symbol = post?.community?.communityId,
            let post = post,
            let user = post.author
        else {return}
        let donateVC = CMDonateVC(selectedBalanceSymbol: symbol, receiver: user, message: post)
        vc.show(donateVC, sender: nil)
    }
    
    func postStatsViewDonatorsDidTouch(_ postStatsView: PostStatsView) {
        guard let viewController = (self as? UIViewController) ?? (self as? UIView)?.parentViewController
        else {return}
        
        guard let post = post else {return}
        
        let vc = ContentRewardsVC(content: post)
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
