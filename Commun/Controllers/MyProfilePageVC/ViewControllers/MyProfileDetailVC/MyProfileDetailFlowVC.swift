//
//  MyProfileDetailFlowVC.swift
//  Commun
//
//  Created by Chung Tran on 7/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class MyProfileDetailFlowVC: BaseVerticalStackVC {
    // MARK: - Properties
    var profile: ResponseAPIContentGetProfile?
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        setLeftNavBarButtonForGoingBack()
    }
    
    override func bind() {
        super.bind()
        
        UserDefaults.standard.rx.observe(Data.self, Config.currentUserGetProfileKey)
            .map {$0 == nil ? nil : try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: $0!)}
            .subscribe(onNext: { profile in
                self.profile = profile
                self.profileDidUpdate()
            })
            .disposed(by: disposeBag)
    }
    
    func profileDidUpdate() {
        self.reloadData()
    }
    
    func reloadData() {
        
    }
    
    // MARK: - ViewBuilder
    func separator() -> UIView { UIView(height: 2, backgroundColor: .appLightGrayColor)}
    
    func createTextField(allowWhiteSpaces: Bool = true) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
        return tf
    }
}
