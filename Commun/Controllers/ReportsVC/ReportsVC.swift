//
//  ReportsVC.swift
//  Commun
//
//  Created by Chung Tran on 11/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class ReportsVC: BaseVerticalStackViewController {
    // MARK: - Subviews
    lazy var closeButton = UIButton.circleGray(imageName: "close-x")
    
    // MARK: - Properties
    
    // MARK: - Initializers
    init() {
        super.init(actions: RestAPIManager.rx.ReportReason.allCases.map({ (reason) -> Action in
            Action(title: reason.rawValue, icon: nil)
        }))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        title = "please select some reasons".localized().uppercaseFirst
        setRightNavBarButton(with: closeButton)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    override func viewForAction(_ action: BaseVerticalStackViewController.Action) -> UIView {
        let actionView = ReportOptionView(height: 58, backgroundColor: .white)
        actionView.checkBox.isUserInteractionEnabled = false
        actionView.titleLabel.text = action.title
        actionView.checkBox.isSelected = action.isSelected
        return actionView
    }
    
    override func didSelectAction(_ action: Action) {
        guard let index = actions.firstIndex(where: {$0.title == action.title})
            else {return}
        actions[index].isSelected = !actions[index].isSelected
        (viewForActionAtIndex(index) as! ReportOptionView).checkBox.isSelected = actions[index].isSelected
    }
}
