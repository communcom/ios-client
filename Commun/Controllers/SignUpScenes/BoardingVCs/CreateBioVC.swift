//
//  CreateBioVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class CreateBioVC: ProfileEditBioVC, SignUpRouter {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonDidTouch(_ sender: Any) {
        
        // TODO: save bio
        
        endSigningUp()
    }
    
    @IBAction func skipButtonDidTouch(_ sender: Any) {
        endSigningUp()
    }
}
