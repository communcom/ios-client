//
//  UserProfilePageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/15/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension UserProfilePageVC {
    @objc func moreActionsButtonDidTouch(_ sender: Any) {
        let headerView = UIView(height: 40)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        avatarImageView.observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let userNameLabel = UILabel.with(text: viewModel.profile.value?.username, textSize: 15, weight: .semibold)
        headerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(toSuperviewEdge: .top)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userNameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        let userIdLabel = UILabel.with(text: "@\(viewModel.profile.value?.userId ?? "")", textSize: 12, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(style: .profile, headerView: headerView, actions: [
            CommunActionSheet.Action(title: "block".localized().uppercaseFirst, icon: UIImage(named: "profile_options_blacklist"), handle: {
                
                self.showAlert(
                    title: "block user".localized().uppercaseFirst,
                    message: "do you really want to block".localized().uppercaseFirst + " \(self.viewModel.profile.value?.username ?? "this user")" + "?",
                    buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst],
                    highlightedButtonIndex: 1) { (index) in
                        if index != 0 {return}
                        self.blockUser()
                    }
            })
        ]) {
            
        }
    }
    
    func blockUser() {
        guard let userId = viewModel.profile.value?.userId else {return}
        RestAPIManager.instance.rx.block(userId)
            .subscribe(onSuccess: { _ in
                self.showAlert(
                title: "user blocked".localized().uppercaseFirst,
                message: "You've blocked" + " \(self.viewModel.profile.value?.username ?? "this user")" + "\n" + "we're sorry that you've had this experience".localized().uppercaseFirst + ".") { _ in
                    self.viewModel.profile.value?.notifyDeleted()
                    self.back()
                }
            }) { (error) in
                self.showError(error)
            }
            .disposed(by: disposeBag)
        
    }
}
