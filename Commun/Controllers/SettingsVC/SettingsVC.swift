//
//  SettingsVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import RxDataSources

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
                sections.append(
                    .firstSection(header: "General", items: [
                        .option((key: "Interface language", value: lang.name)),
                        .option((key: "NSFW content", value: nsfw.localized()))
                    ])
                )
                
                // second section
                var rows = [Section.CustomData]()
                if let pushShow = pushShow, isNotificationOn {
                    rows += [
                        .switcher((key: NotificationSettingType.upvote.rawValue, value: pushShow.upvote)),
                        .switcher((key: NotificationSettingType.downvote.rawValue, value: pushShow.downvote)),
                        .switcher((key: NotificationSettingType.points.rawValue, value: pushShow.transfer)),
                        .switcher((key: NotificationSettingType.comment.rawValue, value: pushShow.reply)),
                        .switcher((key: NotificationSettingType.mention.rawValue, value: pushShow.mention)),
                        .switcher((key: NotificationSettingType.rewardsPosts.rawValue, value: pushShow.reward)),
                        .switcher((key: NotificationSettingType.rewardsVote.rawValue, value: pushShow.curatorReward)),
                        .switcher((key: NotificationSettingType.following.rawValue, value: pushShow.subscribe)),
                        .switcher((key: NotificationSettingType.repost.rawValue, value: pushShow.repost))
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
        
        // For headerInSection
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }

}

//// MARK: - UITableViewDelegate
//extension SettingsVC: UITableViewDelegate {

//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            if indexPath.row == 0 {
//                if let vc = controllerContainer.resolve(LanguageVC.self) {
//                    vc.delegate = self
//                    let nav = UINavigationController(rootViewController: vc)
//                    self.present(nav, animated: true, completion: nil)
//                }
//            }
//
//            else if indexPath.row == 1 {
//                let alert = UIAlertController(title: nil, message: "Select alert", preferredStyle: .actionSheet)
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                alert.addAction(UIAlertAction(title: "Always alert", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
//

//// MARK: - SettingsButtonCellDelegate
//extension SettingsVC: SettingsButtonCellDelegate {
//    func buttonDidTap(on cell: SettingsButtonCell) {
//        if cell.button.titleLabel?.text == "Logout".localized() {
//            showAlert(title: "Logout".localized(), message: "Do you really want to logout", buttonTitles: ["Ok".localized(), "Cancel".localized()], highlightedButtonIndex: 1) { (index) in
//
//                if index == 0 {
//                    do {
//                        try CurrentUser.logout()
//                        AppDelegate.reloadSubject.onNext(true)
//                    } catch {
//                        self.showError(error)
//                    }
//                }
//            }
//
//            return
//        }
//
//        let alert = UIAlertController(title: "Change all password",
//                                      message: "Changing passwords will save your wallet if someone saw your password.",
//                                      preferredStyle: .alert)
//        alert.addTextField { field in
//            field.placeholder = "Paste owner password"
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
//            print("Update password")
//        }))
//
//        present(alert, animated: true, completion: nil)
//    }
//}
//
//
//// MARK: - LanguageVCDelegate
//extension SettingsVC: LanguageVCDelegate {
//    func didSelectLanguage(_ language: Language) {
//        NetworkService.shared.setBasicOptions(lang: language)
//
//        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GeneralSettingCell {
//            cell.settingValueLabel.text = language.name.components(separatedBy: " ").first ?? "English".localized()
//        }
//    }
//}
//
//
//// MARK: - NotificationSettingCellDelegate
//extension SettingsVC: NotificationSettingCellDelegate {
//    func didFailWithError(error: Error) {
//        var message = error.localizedDescription
//
//        if let error = error as? ErrorAPI {
//            message = error.caseInfo.message
//        }
//
//        self.showAlert(title: "Error".localized(), message: message)
//    }
//}
