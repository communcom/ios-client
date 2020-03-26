//
//  NotificationSettingsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class NotificationSettingsViewModel: BaseViewModel {
    // MARK: - Properties
    let loadingState    = BehaviorRelay<LoadingState>(value: .loading)
    let disabledTypes   = BehaviorRelay<[String]?>(value: [])
    
    override init() {
        super.init()
        defer {
            getSettings()
        }
    }
    
    func getSettings() {
        loadingState.accept(.loading)
        RestAPIManager.instance.notificationsGetPushSettings()
            .map {$0.disabled}
            .subscribe(onSuccess: { (disabledTypes) in
                self.disabledTypes.accept(disabledTypes)
                self.loadingState.accept(.finished)
            }) { (error) in
                self.loadingState.accept(.error(error: error))
            }
            .disposed(by: disposeBag)
    }
}
