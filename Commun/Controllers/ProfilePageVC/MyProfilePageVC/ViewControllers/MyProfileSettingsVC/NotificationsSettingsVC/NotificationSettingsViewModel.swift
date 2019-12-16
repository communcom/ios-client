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
    let notificationOn  = BehaviorRelay<Bool>(value: UserDefaults.standard.object(forKey: Config.currentUserPushNotificationOn) == nil ? true: UserDefaults.standard.bool(forKey: Config.currentUserPushNotificationOn))
    let options         = BehaviorRelay<ResponseAPIGetOptionsNotifyShow?>(value: nil)
    
    override init() {
        super.init()
        defer {bind()}
    }
    
    func bind() {
        // bind notificationOn
        UserDefaults.standard.rx
            .observe(Bool.self, Config.currentUserPushNotificationOn)
            .skip(1)
            .filter {$0 != nil}
            .map {$0!}
            .bind(to: notificationOn)
            .disposed(by: disposeBag)
        
        // notification on
        notificationOn
            .subscribe(onNext: {[weak self] (isOn) in
                if isOn {
                    self?.options.accept(ResponseAPIGetOptionsNotifyShow.allOn)
                } else {
                    self?.options.accept(nil)
                }
            })
            .disposed(by: disposeBag)
        
        getOptionsPushShow()
    }
    
    func getOptionsPushShow() {
        guard notificationOn.value else {return}
        RestAPIManager.instance.getPushNotify()
            .map {$0.notify.show}
            .subscribe(onSuccess: { [weak self] (show) in
                self?.options.accept(show)
            })
            .disposed(by: disposeBag)
    }
    
    func togglePushNotify(on: Bool) {
        let operation = on ? RestAPIManager.instance.pushNotifyOn() :
            RestAPIManager.instance.pushNotifyOff()
                
        operation
            .subscribe(onCompleted: {
            
            })
            .disposed(by: disposeBag)
    }
}
