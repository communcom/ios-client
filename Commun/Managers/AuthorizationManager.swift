//
//  AuthenticationManager.swift
//  Commun
//
//  Created by Chung Tran on 2/7/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AuthorizationManager {
    // MARK: - Nested type
    enum Status: Equatable {
        static func == (lhs: AuthorizationManager.Status, rhs: AuthorizationManager.Status) -> Bool {
            switch (lhs, rhs) {
            case (.authorizing, .authorizing):
                return true
            case (.boarding(let step1), .boarding(let step2)):
                return step1 == step2
            case (.authorized, .authorized):
                return true
            case (.registering(let step1), .registering(let step2)):
                return step1 == step2
            case (.authorizingError(let error1), .authorizingError(let error2)):
                return error1.localizedDescription == error2.localizedDescription
            default:
                return false
            }
        }
        
        case authorizing
        case boarding(step: CurrentUserSettingStep)
        case authorized
        case registering(step: CurrentUserRegistrationStep)
        case authorizingError(error: Error)
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let status = BehaviorRelay<Status>(value: .authorizing)
    
    // MARK: - Singleton
    static let shared = AuthorizationManager()
    private init() {
        bind()
    }
    
    private func bind() {
        SocketManager.shared.signed
            .filter {$0}
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (_) in
                self.authorize()
            })
            .disposed(by: disposeBag)
    }
    
    func logout() throws {
        try KeychainManager.deleteUser()
        forceReAuthorize()
    }
    
    func forceReAuthorize() {
        self.status.accept(.authorizing)
        authorize()
    }
    
    private func authorize() {
        let step = KeychainManager.currentUser()?.registrationStep ?? .firstStep
        if step == .registered || step == .relogined {
            // If first setting is uncompleted
            let settingStep = KeychainManager.currentUser()?.settingStep ?? .backUpICloud
            if settingStep != .completed {
                self.status.accept(.boarding(step: settingStep))
                return
            } else {
                RestAPIManager.instance.authorize()
                    .subscribe(onSuccess: { (_) in
                        self.deviceSetInfo()
                        self.status.accept(.authorized)
                    }) { (error) in
                        self.status.accept(.authorizingError(error: error))
                    }
                    .disposed(by: disposeBag)
            }
        } else {
            self.status.accept(.registering(step: step))
        }
    }
    
    private func deviceSetInfo() {
        // set info
        let key = "AppDelegate.setInfo"
        if !UserDefaults.standard.bool(forKey: key) {
            let offset = -TimeZone.current.secondsFromGMT() / 60
            RestAPIManager.instance.deviceSetInfo(timeZoneOffset: offset)
                .subscribe(onSuccess: { (_) in
                    UserDefaults.standard.set(true, forKey: key)
                })
                .disposed(by: disposeBag)
        }
        
        // fcm token
        if !UserDefaults.standard.bool(forKey: Config.currentDeviceDidSendFCMToken)
        {
            UserDefaults.standard.rx.observe(String.self, Config.currentDeviceFcmTokenKey)
                .filter {$0 != nil}
                .map {$0!}
                .take(1)
                .asSingle()
                .flatMap {RestAPIManager.instance.deviceSetFcmToken($0)}
                .subscribe(onSuccess: { (_) in
                    UserDefaults.standard.set(true, forKey: Config.currentDeviceDidSendFCMToken)
                })
                .disposed(by: disposeBag)
        }
    }
}
