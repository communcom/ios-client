//
//  WalletCarousel.swift
//  Commun
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import CircularCarousel

class WalletCarousel: CircularCarousel {
    // MARK: - Constants

    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
