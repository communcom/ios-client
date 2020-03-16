//
//  CreatePasswordViewModel.swift
//  Commun
//
//  Created by Chung Tran on 3/16/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CreatePasswordViewModel: BaseViewModel {
    let isShowingPassword = BehaviorRelay<Bool>(value: false)
}
