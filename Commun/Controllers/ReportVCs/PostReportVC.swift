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

class PostReportVC: ReportVC {
    // MARK: - Properties
    let post: ResponseAPIContentGetPost
    let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost) {
        self.post = post
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
        
        showIndetermineHudWithMessage("reporting".localized().uppercaseFirst + "...")
        RestAPIManager.instance.rx.report(communityID: post.community.communityId, autorID: post.author?.userId ?? "", permlink: post.contentId.permlink, reasons: choosedReasons)
//            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (_) in
                self.hideHud()
                self.dismiss(animated: false) {
                    self.post.notifyDeleted()
                }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
