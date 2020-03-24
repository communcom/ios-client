//
//  CMSwipeBackConfiguration.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 19.03.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import SwipeTransition

class CMSwipeBackConfiguration: SwipeBackConfiguration {
    override var transitionDuration: TimeInterval {
        get { return 1.5 }
        set { super.transitionDuration = newValue }
    }
}
