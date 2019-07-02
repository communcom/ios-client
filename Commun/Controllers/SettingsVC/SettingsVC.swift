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

class SettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let bag = DisposeBag()
    
    var generalCells: [UITableViewCell] = []
    var notificationCells: [UITableViewCell] = []
    var passwordsCells: [UITableViewCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "GeneralSettingCell", bundle: nil), forCellReuseIdentifier: "GeneralSettingCell")
        tableView.register(UINib(nibName: "NotificationSettingCell", bundle: nil), forCellReuseIdentifier: "NotificationSettingCell")
        tableView.register(UINib(nibName: "SettingsButtonCell", bundle: nil), forCellReuseIdentifier: "SettingsButtonCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension//56
        
        self.title = "Settings"
        
        // get options
        NetworkService.shared.getOptions()
            .subscribe(onCompleted: {
                self.makeCells()
            })
            .disposed(by: bag)
        
        makeCells()
    }

}

extension SettingsVC {
    
    func makeCells() {
        // General
        generalCells = []
        let language = tableView.dequeueReusableCell(withIdentifier: "GeneralSettingCell") as! GeneralSettingCell
        language.setupCell(setting: GeneralSetting(name: "Interface language", value: "English"))
        generalCells.append(language)
        
        let content = tableView.dequeueReusableCell(withIdentifier: "GeneralSettingCell") as! GeneralSettingCell
        content.setupCell(setting: GeneralSetting(name: "NSFW content", value: "Always alert"))
        generalCells.append(content)
        
        // Notifications
        notificationCells = []
        for type in NotificationSettingType.allCases {
            let notificationCell = tableView.dequeueReusableCell(withIdentifier: "NotificationSettingCell") as! NotificationSettingCell
            notificationCell.setupCell(withType: type)
            notificationCell.delegate = self
            notificationCells.append(notificationCell)
        }

        #warning("setup password")
//        for (key, value) in KeychainManager.loadData(byUserID: Config.currentUser.id ?? "", withKey: Config.currentUser.activeKey ?? "") ?? [:] {
//            // Пока нет паролей...
//        }
        
        // PasswordsCells
        passwordsCells = []
        let changePasswordCell = tableView.dequeueReusableCell(withIdentifier: "SettingsButtonCell") as! SettingsButtonCell
        changePasswordCell.delegate = self
        changePasswordCell.button.setTitle("Change all password".localized(), for: .normal)
        changePasswordCell.button.setTitleColor(.appMainColor, for: .normal)
        passwordsCells.append(changePasswordCell)
        
        // Logout
        let logoutCell = tableView.dequeueReusableCell(withIdentifier: "SettingsButtonCell") as! SettingsButtonCell
        logoutCell.delegate = self
        logoutCell.button.setTitleColor(.red, for: .normal)
        logoutCell.button.setTitle("Logout".localized(), for: .normal)
        passwordsCells.append(logoutCell)
        
        tableView.reloadData()
    }
    
}

extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return generalCells.count
        }
        if section == 1 {
            return notificationCells.count
        }
        if section == 2 {
            return passwordsCells.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return generalCells[indexPath.row]
        }
        if indexPath.section == 1 {
            return notificationCells[indexPath.row]
        }
        if indexPath.section == 2 {
            return passwordsCells[indexPath.row]
        }
        return UITableViewCell()
    }
    
}

extension SettingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let vc = controllerContainer.resolve(LanguageVC.self) {
                    vc.delegate = self
                    let nav = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true, completion: nil)
                }
                
            }
            else if indexPath.row == 1 {
                let alert = UIAlertController(title: nil, message: "Select alert", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Always alert", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 16, y: 15, width: self.view.frame.width, height: 30))
        
        switch section {
        case 0:
            label.text = "General"
            break
        case 1:
            label.text = "Notifications"
            break
        case 2:
            label.text = "Passwords"
            break
        default:
            label.text = ""
        }
        
        label.font = .systemFont(ofSize: 22)
        view.addSubview(label)
        
        return view
    }
    
}

extension SettingsVC: SettingsButtonCellDelegate {
    
    func buttonDidTap(on cell: SettingsButtonCell) {
        if cell.button.titleLabel?.text == "Logout".localized() {
            showAlert(title: "Logout".localized(), message: "Do you really want to logout", buttonTitles: ["Ok".localized(), "Cancel".localized()], highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    do {
                        try Auth.logout()
                    } catch {
                        self.showGeneralError()
                    }
                }
            }
            return
        }
        
        let alert = UIAlertController(title: "Change all password",
                                      message: "Changing passwords will save your wallet if someone saw your password.",
                                      preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Paste owner password"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
            print("Update password")
        }))
        present(alert, animated: true, completion: nil)
    }
    
}

extension SettingsVC: LanguageVCDelegate {
    
    func didSelectLanguage(_ language: Language) {
        NetworkService.shared.setBasicOptions(lang: language)
    }
    
}

extension SettingsVC: NotificationSettingCellDelegate {
    func didFailWithError(error: Error) {
        var message = error.localizedDescription
        if let error = error as? ErrorAPI {
            message = error.caseInfo.message
        }
        self.showAlert(title: "Error".localized(), message: message)
    }
}
