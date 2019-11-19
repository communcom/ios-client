//
//  LoadingState.swift
//  Commun
//
//  Created by Chung Tran on 11/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

enum LoadingState {
    case loading
    case finished
    case error(error: Error)
}
