//
//  ProfilePageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

struct ProfilePageViewModel {
    let profile = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    let bag = DisposeBag()
    
    func loadProfile() {
        NetworkService.shared.getUserProfile()
            .subscribe(onSuccess: { (profile) in
                self.profile.accept(profile)
            }) { (error) in
                print(error)
            }
            .disposed(by: bag)
    }
}
