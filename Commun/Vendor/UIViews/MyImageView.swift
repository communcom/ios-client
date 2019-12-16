//
//  MyImageView.swift
//  Commun
//
//  Created by Chung Tran on 12/12/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class MyImageView: UIImageView {
    var url: String?
    
    func setImage(with url: String) {
        self.url = url
        setImageDetectGif(with: url)
    }
}
