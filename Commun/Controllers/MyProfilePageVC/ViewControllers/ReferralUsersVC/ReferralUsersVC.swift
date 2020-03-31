//
//  ReferralUsersVC.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class ReferralUsersVC: SubsViewController<ResponseAPIContentGetProfile, SubscribersCell> {
    lazy var headerView = ReferralHeaderView(tableView: tableView)
    
    init() {
        let vm = ReferralUsersViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUp() {
        super.setUp()
        headerView.sendButton.addTarget(self, action: #selector(sendButtonDidTouch), for: .touchUpInside)
        headerView.shareButton.addTarget(self, action: #selector(shareButtonDidTouch), for: .touchUpInside)
        headerView.copyButton.addTarget(self, action: #selector(copyButtonDidTouch), for: .touchUpInside)
        headerView.learnMoreButton.addTarget(self, action: #selector(infoButtonDidTouch), for: .touchUpInside)
    }
    
    override func bind() {
        super.bind()
        headerView.textField.rx.text.orEmpty
            .map {$0.count == 12}
            .bind(to: headerView.sendButton.rx.isDisabled)
            .disposed(by: disposeBag)
    }
    
    override func handleListEmpty() {
        let title = "no referral users"
        let description = "no referral users found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func configureCell(with item: ResponseAPIContentGetProfile, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(with: item, indexPath: indexPath) as! SubscribersCell
        cell.followButton.isHidden = true
        return cell
    }
    
    @objc func shareButtonDidTouch() {
        let string = "Sign up for the promotional code \(Config.currentUser?.id ?? "") and get 1 Commun free"
        
        ShareHelper.share([
            string,
            URL(string: "https://commun.com/?invite=\(Config.currentUser?.id ?? "")")!]
        )
    }
    
    @objc func copyButtonDidTouch() {
        let string = "Sign up for the promotional code \(Config.currentUser?.id ?? "") and get 1 Commun free"
        UIPasteboard.general.string = "\(string)\nhttps://commun.com/?invite=\(Config.currentUser?.id ?? "")"
        self.showDone("copied to clipboard".localized().uppercaseFirst)
    }
    
    @objc func infoButtonDidTouch() {
        load(url: "https://commun.com/faq")
    }
    
    @objc func sendButtonDidTouch() {
        showIndetermineHudWithMessage("adding referralId".localized().uppercaseFirst + "...")
        RestAPIManager.instance.appendReferralParent(referralId: headerView.textField.text!)
            .subscribe(onSuccess: { (_) in
                self.hideHud()
                self.showDone("referralId added".localized().uppercaseFirst + "!")
                self.headerView.textField.text = nil
                self.headerView.textField.sendActions(for: .valueChanged)
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
