//
//  BasicEditorViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class BasicEditorViewModel: PostEditorViewModel {
    let attachment = BehaviorRelay<TextAttachment?>(value: nil)
}
