//
//  ProfileChooseAvatarVC.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class ProfileChooseAvatarVC: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var viewModel = ProfileChooseAvatarViewModel()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Bind views
        bindUI()
    }
    
    func bindUI() {
        viewModel.avatar
            .filter {$0 != nil}
            .map {$0!}
            .bind(to: avatarImageView.rx.image)
            .disposed(by: bag)
    }

}
