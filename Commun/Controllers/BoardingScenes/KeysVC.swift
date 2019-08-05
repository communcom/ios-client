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
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var completion: (()->Void)?
    var onBoarding = true
    

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
        
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide back button
        navigationItem.setHidesBackButton(true, animated: false)
        
        // Set title
        title = "Backup keys".localized()
        
        bindUI()
    }
    
    
    // MARK: - Custom Functions
    func bindUI() {
        
        // Retrieve keys
        let user = KeychainManager.currentUser()
        
        Observable.just(user)
            .map {user -> [(key: String, value: String)] in
                var keys = [(key: String, value: String)]()
                
                if let key = user?.masterKey {
                    keys.append((key: "Master key", value: key))
                }
                
                if let key = user?.memoKeys?.privateKey {
                    keys.append((key: "Memo key", value: key))
                }
                if let key = user?.ownerKeys?.privateKey {
                    keys.append((key: "Owner key", value: key))
                }
                if let key = user?.activeKeys?.privateKey {
                    keys.append((key: "Active key", value: key))
                }
                if let key = user?.postingKeys?.privateKey {
                    keys.append((key: "Posting key", value: key))
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

    
    // MARK: - Actions
    @IBAction func backupIcloudDidTouch(_ sender: Any) {
        do {
            try RestAPIManager.instance.rx.backUpICloud(onBoarding: onBoarding)
            if completion == nil {
                self.boardingNextStep()
            } else {
                showDone("Backed up") {
                    self.completion?()
                }
            }
        } catch {
            showError(error)
        }
        
    }
    
    @IBAction func shareButtonDidTouch(_ sender: Any) {
        guard let user = KeychainManager.currentUser() else {return}
        
        let textToShare = [String(format: "id:\n\"%@\"\n\nname:\n\"%@\"\n\nmaster key:\n\"%@\"\n\nmemo key:\n\"%@\"\n\nowner key:\n\"%@\"\n\nactive key:\n\"%@\"\n\nposting key:\n\"%@\"", user.id ?? "", user.name ?? "", user.masterKey ?? "", user.memoKeys?.privateKey ?? "", user.ownerKeys?.privateKey ?? "", user.activeKeys?.privateKey ?? "", user.postingKeys?.privateKey ?? "")]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view // so that iPads won't crash
        
        // present the view controller
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func laterButtonDidTouch(_ sender: Any) {
        do {
            if onBoarding {
                try KeychainManager.save([
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
