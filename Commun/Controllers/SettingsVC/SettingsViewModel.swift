//
//  SettingsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift
import Localize_Swift

class SettingsViewModel {
    private let bag = DisposeBag()
    
    let currentLanguage = BehaviorRelay<Language>(value: Language.currentLanguage)
    let nsfwContent     = BehaviorRelay<String>(value: "Alway alert")
    let biometryEnabled = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: Config.currentUserBiometryAuthEnabled))
    let notificationOn  = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: Config.currentUserPushNotificationOn))
    let optionsPushShow = BehaviorRelay<ResponseAPIGetOptionsNotifyShow?>(value: nil)
    let userKeys        = BehaviorRelay<[String: String]?>(value: nil)
    
    init() {
        // bind notificationOn
        UserDefaults.standard.rx
            .observe(Bool.self, Config.currentUserPushNotificationOn)
            .skip(1)
            .filter {$0 != nil}
            .map {$0!}
            .bind(to: notificationOn)
            .disposed(by: bag)
        
        // current language
        currentLanguage
            .skip(1)
            .subscribe(onNext: { (language) in
                Localize.setCurrentLanguage(language.shortCode)
            })
            .disposed(by: bag)
        
        getOptionsPushShow()
        getKeys()
    }
    
    func getOptionsPushShow() {
        RestAPIManager.instance.rx.getPushNotify()
            .map {$0.notify.show}
            .asObservable()
            .bind(to: optionsPushShow)
            .disposed(by: bag)
    }
    
    func getKeys() {
        guard let user = Config.currentUser else {return}
        
        var keys = [String: String]()
        
        if let postingKey = user.postingKeys?.privateKey {
            keys["Posting key"] = postingKey
        }
        
        if let activeKey = user.activeKeys?.privateKey {
            keys["Active key"] = activeKey
        }
        
        if let ownerKey = user.ownerKeys?.privateKey {
            keys["Owner key"] = ownerKey
        }
        
        if let memoKey = user.memoKeys?.privateKey {
            keys["Memo key"] = memoKey
        }
        
        userKeys.accept(keys)
    }
    
    func togglePushNotify(on: Bool) -> Completable {
        return on ? RestAPIManager.instance.rx.pushNotifyOn() :
            RestAPIManager.instance.rx.pushNotifyOff()
    }
}
