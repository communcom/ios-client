//
//  ViewTag.swift
//  Commun
//
//  Created by Chung Tran on 3/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

enum ViewTag: Int, Equatable {
    case loadingView = 99990
    case loadingFooterView = 99991
    case postLoadingFooterView = 99992
    case listErrorFooterView = 99993
    case emptyPlaceholderView = 99994
    case notificationsLoadingFooterView = 99995
    case commentLoadingFooterView = 99996
    case commentEmptyFooterViewTag = 99997
    case blurView = 99998
    case reCaptchaTag = 99999
}
