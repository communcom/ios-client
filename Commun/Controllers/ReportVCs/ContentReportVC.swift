//
//  PostReportVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class ContentReportVC<T: ListItemType>: ReportVC {
    // MARK: - Properties
    let content: T
    
    // MARK: - Initializers
    init(content: T) {
        self.content = content
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func sendButtonDidTouch() {
        let choosedReasons = actions.filter {$0.isSelected == true}
            .compactMap {RestAPIManager.rx.ReportReason(rawValue: $0.title)}
        guard choosedReasons.count > 0 else {
            showAlert(title: "reason needed".localized().uppercaseFirst, message: "you must choose at least one reason".localized().uppercaseFirst)
            return
        }
        
        var communityId: String?
        var authorId: String?
        var permlink: String?
        if let post = content as? ResponseAPIContentGetPost {
            communityId = post.community.communityId
            authorId = post.author?.userId
            permlink = post.contentId.permlink
        }
        
        if let comment = content as? ResponseAPIContentGetComment {
            communityId = comment.community?.communityId
            authorId = comment.author?.userId
            permlink = comment.contentId.permlink
        }
        
        showIndetermineHudWithMessage("reporting".localized().uppercaseFirst + "...")
        RestAPIManager.instance.rx.report(communityID: communityId ?? "", autorID: authorId ?? "", permlink: permlink ?? "", reasons: choosedReasons)
//            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (_) in
                self.hideHud()
                self.showAlert(title: "thank you for reporting this post".localized().uppercaseFirst, message: "we have flagged this post for investigation. Thank you for being with us".localized().uppercaseFirst) { _ in
                    self.dismiss(animated: true) {
                        self.content.notifyDeleted()
                    }
                }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
