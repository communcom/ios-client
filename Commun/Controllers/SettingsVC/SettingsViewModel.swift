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

struct SettingsViewModel {
    private let bag = DisposeBag()
    
    let currentLanguage = BehaviorRelay<Language>(value: Language.currentLanguage)
    let nsfwContent     = BehaviorRelay<String>(value: "Alway alert")
    let optionsPushShow = BehaviorRelay<ResponseAPIGetOptionsNotifyShow?>(value: nil)
    let userKeys        = BehaviorRelay<[String: String]?>(value: nil)
    
    init() {
        getOptionsPushShow()
        getKeys()
    }
    
    func getOptionsPushShow() {
        NetworkService.shared.getOptions()
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
}
