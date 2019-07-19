//
//  SettingsVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift
import RxDataSources
import LocalAuthentication

class SettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    let viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure views
        tableView.rowHeight = UITableView.automaticDimension//56
        title = "Settings".localized()
        
        // Bind Views
        bindUI()
    }
    
    func bindUI() {
        // Bind table
        Observable.combineLatest(
                viewModel.currentLanguage,
                viewModel.nsfwContent,
                viewModel.notificationOn,
                viewModel.optionsPushShow,
                viewModel.userKeys
            )
            .map {(lang, nsfw, isNotificationOn, pushShow, keys) -> [Section] in
                var sections = [Section]()
                
                // first section
                let currentBiometryType = LABiometryType.current
                sections.append(
                    .firstSection(header: "General", items: [
                        .option((key: "Interface language", value: lang.name)),
                        .option((key: "NSFW content", value: nsfw.localized())),
                        .option((key: "Change passcode", value: "")),
                        .switcher((key: "Enable \(currentBiometryType.stringValue)", value: true, image: currentBiometryType.icon))
                    ])
                )
                
                // second section
                var rows = [Section.CustomData]()
                if let pushShow = pushShow, isNotificationOn {
                    rows += [
                        .switcher((key: NotificationSettingType.upvote.rawValue, value: pushShow.upvote, image: nil)),
                        .switcher((key: NotificationSettingType.downvote.rawValue, value: pushShow.downvote, image: nil)),
                        .switcher((key: NotificationSettingType.points.rawValue, value: pushShow.transfer, image: nil)),
                        .switcher((key: NotificationSettingType.comment.rawValue, value: pushShow.reply, image: nil)),
                        .switcher((key: NotificationSettingType.mention.rawValue, value: pushShow.mention, image: nil)),
                        .switcher((key: NotificationSettingType.rewardsPosts.rawValue, value: pushShow.reward, image: nil)),
                        .switcher((key: NotificationSettingType.rewardsVote.rawValue, value: pushShow.curatorReward, image: nil)),
                        .switcher((key: NotificationSettingType.following.rawValue, value: pushShow.subscribe, image: nil)),
                        .switcher((key: NotificationSettingType.repost.rawValue, value: pushShow.repost, image: nil))
                    ]
                }
                sections.append(
                    .secondSection(header: "Notifications", items: rows)
                )
                
                // third section
                rows = [Section.CustomData]()
                if let keys = keys {
                    for (k,v) in keys {
                        rows.append(.keyValue((key: k, value: v)))
                    }
                }
                sections.append(.thirdSection(header: "Private keys".localized(), items: rows))
                
                // forth section
                sections.append(.forthSection(items: [
                    .button(.changeAllPassword),
                    .button(.logout)
                ]))
                
                return sections
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        // Action
        tableView.rx.itemSelected
            .subscribe(onNext: { (indexPath) in
                switch indexPath.section {
                case 0:
                    switch indexPath.row {
                    case 0:
                        let vc = controllerContainer.resolve(LanguageVC.self)!
                        let nav = UINavigationController(rootViewController: vc)
                        self.present(nav, animated: true, completion: nil)
                        vc.didSelectLanguage
                            .subscribe(onNext: { (language) in
                                self.viewModel.currentLanguage.accept(language)
                            })
                            .disposed(by: self.bag)
                    case 1:
                        let alert = UIAlertController(title: nil, message: "Select alert".localized(), preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "Always alert".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                    break
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        // For headerInSection
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }

}

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
            viewModel.optionsPushShow.accept(newValue)
            RestAPIManager.instance.rx.setPushNotify(options: newValue.toParam())
                .subscribe(onError: {[weak self] error in
                    self?.showError(error)
                    self?.viewModel.optionsPushShow.accept(original)
                })
                .disposed(by: bag)
        }
    }
}
