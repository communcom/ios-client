//
//  PostReportVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class ContentReportVC<T: ResponseAPIContentMessageType>: ReportVC {
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
        guard checkValues(),
            let communityId = content.community?.communityId,
            let authorId = content.author?.userId
        else {
            return
        }
        
        let permlink = content.contentId.permlink
        
        showIndetermineHudWithMessage("reporting".localized().uppercaseFirst + "...")
        
        BlockchainManager.instance.report(communityID: communityId, autorID: authorId, permlink: permlink, reasons: choosedReasons, message: otherReason)
//            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (_) in
                self.hideHud()
                self.showAlert(title: "thank you for reporting this post".localized().uppercaseFirst, message: "we have flagged this post for investigation".localized().uppercaseFirst) { _ in
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
