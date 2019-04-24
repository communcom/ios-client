//
//  ProfileChooseAvatarViewModel.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa

struct ProfileChooseAvatarViewModel {
    var avatar = BehaviorRelay<UIImage?>(value: nil)
}
