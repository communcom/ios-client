//
//  ListViewModelType.swift
//  Commun
//
//  Created by Chung Tran on 03/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxCocoa

protocol ListViewModelType {
    var loadingHandler: (()->Void)? {get set}
    var listEndedHandler: (()->Void)? {get set}
    var fetchNextErrorHandler: ((Error)->Void)? {get set}
}
