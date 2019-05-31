//
//  UIView+Loading.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import ASSpinnerView

extension UIView {
    func showLoading() {
        let size = height > 76 ? 60: height-16
        
        if self.viewWithTag(9999) != nil {return}
        let spinnerView = ASSpinnerView()
        spinnerView.spinnerLineWidth = size/10
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1)
        spinnerView.tag = 9999
        
        self.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: size).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: size).isActive = true
        self.bringSubviewToFront(spinnerView)
    }
    
    func hideLoading() {
        self.viewWithTag(9999)?.removeFromSuperview()
    }
}
