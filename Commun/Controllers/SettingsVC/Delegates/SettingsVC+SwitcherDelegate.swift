//
//  SettingsVC+SwitcherDelegate.swift
//  Commun
//
//  Created by Chung Tran on 7/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

// MARK: - SwitcherCellDelegate
extension SettingsVC: SettingsSwitcherCellDelegate {
    func switcherDidSwitch(value: Bool, for key: String) {
        // Notification
        if let notificationType = NotificationSettingType(rawValue: key) {
            guard let original = viewModel.optionsPushShow.value else {return}
            var newValue = original
            switch notificationType {
            case .upvote:
                newValue.upvote = value
            case .downvote:
                newValue.downvote = value
            case .points:
                newValue.transfer = value
            case .comment:
                newValue.reply = value
            case .mention:
                newValue.mention = value
            case .rewardsPosts:
                newValue.reward = value
            case .rewardsVote:
                newValue.curatorReward = value
            case .following:
                newValue.subscribe = value
            case .repost:
                newValue.repost = value
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                self.viewModel.optionsPushShow.accept(newValue)
            }
            RestAPIManager.instance.rx.setPushNotify(options: newValue.toParam())
                .subscribe(onError: {[weak self] error in
                    self?.showError(error)
                    self?.viewModel.optionsPushShow.accept(original)
                })
                .disposed(by: bag)
        }
        
        if key == "Use \(self.currentBiometryType.stringValue)" {
            UserDefaults.standard.set(value, forKey: Config.currentUserBiometryAuthEnabled)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                self.viewModel.biometryEnabled.accept(value)
            }
        }
    }
}
