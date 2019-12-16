//
//  SegmentioExtensions.swift
//  Commun
//
//  Created by Chung Tran on 19/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import Segmentio

extension SegmentioOptions {
    static var `default`: SegmentioOptions {
        let indicator = SegmentioIndicatorOptions(type: .bottom,
                                                  ratio: 1,
                                                  height: 2,
                                                  color: #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1))
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.boldSystemFont(ofSize: 15),
                titleTextColor: #colorLiteral(red: 0.6078431373, green: 0.6235294118, blue: 0.6352941176, alpha: 1)
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.boldSystemFont(ofSize: 15),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.boldSystemFont(ofSize: 15),
                titleTextColor: .black
            )
        )
        let options = SegmentioOptions(backgroundColor: .white,
                                       segmentPosition: .fixed(maxVisibleItems: 3),
                                       scrollEnabled: false,
                                       indicatorOptions: indicator,
                                       horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .bottom,
                                                                                                       height: 0,
                                                                                                       color: #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1)),
                                       verticalSeparatorOptions: nil,
                                       imageContentMode: .scaleAspectFit,
                                       labelTextAlignment: .center,
                                       labelTextNumberOfLines: 0,
                                       segmentStates: states,
                                       animationDuration: 0.2)
        
        return options
    }
}
