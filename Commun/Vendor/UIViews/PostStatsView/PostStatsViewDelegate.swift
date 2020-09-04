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
        
        guard let donations = post?.donations else {return}
        let vc = DonationsVC(donations: donations)
        vc.modelSelected = {donation in
            vc.dismiss(animated: true) {
                viewController.showProfileWithUserId(donation.sender.userId)
            }
        }
        
        let navigation = SwipeNavigationController(rootViewController: vc)
        navigation.view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        navigation.modalPresentationStyle = .custom
        navigation.transitioningDelegate = vc
        viewController.present(navigation, animated: true, completion: nil)
    }
}
