//
//  MyCardView.swift
//  Commun
//
//  Created by Chung Tran on 12/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class MyCardView: MyView {
    @objc func close() {
        parentViewController?.dismiss(animated: true, completion: nil)
    }
}
