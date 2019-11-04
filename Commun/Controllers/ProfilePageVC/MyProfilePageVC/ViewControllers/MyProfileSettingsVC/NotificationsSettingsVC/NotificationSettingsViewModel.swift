//
//  NotificationSettingsViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa

class NotificationSettingsViewModel: BaseViewModel {
    // MARK: - Properties
    let loadingState    = BehaviorRelay<LoadingState>(value: .loading)
    let notificationOn  = BehaviorRelay<Bool>(value: UserDefaults.standard.bool(forKey: Config.currentUserPushNotificationOn))
    let options         = BehaviorRelay<ResponseAPIGetOptionsNotifyShow?>(value: nil)
    
    
}
