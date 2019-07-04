//
//  LoadKeysViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
import CyberSwift

class LoadKeysViewModel {
    // MARK: - Class Functions
    func saveKeys() -> Completable {
        return RestAPIManager.instance.rx.toBlockChain()
    }
}
