//
//  UITableView.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import ASSpinnerView

extension UITableView {
    func addLoadingFooterView() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 60))
        let spinnerView = ASSpinnerView()
        spinnerView.spinnerLineWidth = 4
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1)
        containerView.addSubview(spinnerView)
        
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        containerView.bringSubviewToFront(spinnerView)
        
        self.tableFooterView = containerView
    }
}
