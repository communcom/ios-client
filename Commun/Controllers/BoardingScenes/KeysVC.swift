//
//  KeysViewController.swift
//  Commun
//
//  Created by Chung Tran on 11/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxCocoa
import RxSwift

class KeysVC: UIViewController, BoardingRouter {
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    var completion: (()->Void)?
    var onBoarding = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide back button
        navigationItem.setHidesBackButton(true, animated: false)
        
        // Set title
        title = "Backup keys".localized()
        
        bindUI()
    }
    
    func bindUI() {
        
        // Retrieve keys
        let user = KeychainManager.currentUser()
        
        Observable.just(user)
            .map {user -> [String: String] in
                var keys = [String: String]()
                if let key = user?.memoKeys?.privateKey {
                    keys["Memo key"] = key
                }
                if let key = user?.ownerKeys?.privateKey {
                    keys["Owner key"] = key
                }
                if let key = user?.activeKeys?.privateKey {
                    keys["Active key"] = key
                }
                if let key = user?.postingKeys?.privateKey {
                    keys["Posting key"] = key
                }
                return keys
            }
            .bind(to: tableView.rx.items(cellIdentifier: "KeyCell")) { (row, element, cell) in
                let keyTypeLabel = cell.viewWithTag(1) as! UILabel
                let keyLabel = cell.viewWithTag(2) as! UILabel
                keyTypeLabel.text = element.key
                keyLabel.text = element.value
            }
            .disposed(by: disposeBag)
    }

    @IBAction func backupIcloudDidTouch(_ sender: Any) {
        do {
            try RestAPIManager.instance.rx.backUpICloud(onBoarding: onBoarding)
            if completion == nil {
                self.boardingNextStep()
            } else {
                completion!()
            }
        } catch {
            showError(error)
        }
        
    }
    @IBAction func shareButtonDidTouch(_ sender: Any) {
        
        guard let user = KeychainManager.currentUser() else {return}
        
        let textToShare = [String(format: "id:\n\"%@\"\n\nname:\n\"%@\"\n\nmemo key:\n\"%@\"\n\nowner key:\n\"%@\"\n\nactive key:\n\"%@\"\n\nposting key:\n\"%@\"", user.id ?? "", user.name ?? "", user.memoKeys?.privateKey ?? "", user.ownerKeys?.privateKey ?? "", user.activeKeys?.privateKey ?? "", user.postingKeys?.privateKey ?? "")]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view // so that iPads won't crash
        
        // present the view controller
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func laterButtonDidTouch(_ sender: Any) {
        do {
            if onBoarding {
                try KeychainManager.save(data: [
                    Config.settingStepKey: CurrentUserSettingStep.setAvatar.rawValue
                ])
                boardingNextStep()
                return
            }
            completion?()
        } catch {
            showError(error)
        }
        
    }
}
