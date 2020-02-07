//
//  MyCardView.swift
//  Commun
//
//  Created by Chung Tran on 12/13/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

enum CMCardViewParameters {
    case user
    case topState
    case rewardState
    
    var title: String {
        switch self {
        case .user: return "modal view user title".localized().uppercaseFirst
        case .topState: return "modal view top state title".localized().uppercaseFirst
        case .rewardState: return "modal view reward state title".localized().uppercaseFirst
        }
    }
    
    var note: String {
        switch self {
        case .user: return "modal view user note".localized().uppercaseFirst
        case .topState: return "modal view top state note".localized().uppercaseFirst
        case .rewardState: return "modal view reward state note".localized().uppercaseFirst
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .user: return "modal view user button title".localized().uppercaseFirst
        case .topState: return "modal view top state button title".localized().uppercaseFirst
        case .rewardState: return "modal view reward state button title".localized().uppercaseFirst
        }
    }
}

class MyCardView: MyView {
    // MARK: - Properties
    var viewParameters: CMCardViewParameters!
    var completionDismissWithAction: ((Bool) -> Void)?
    
    // MARK: - Class Initialization
    init(withFrame frame: CGRect, andParameters viewParameters: CMCardViewParameters = .user) {
        self.viewParameters = viewParameters
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc func close() {
        completionDismissWithAction!(false)
    }
    
    @objc func openLink(_ sender: UIButton) {
        completionDismissWithAction!(true)
    }
}
