//
//  LoadKeysVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoadKeysVC: UIViewController {

    @IBOutlet weak var downloadKeysButton: UIButton!
    
    var viewModel: LoadKeysViewModel?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeActions()
    }

    func makeActions() {
        downloadKeysButton.rx.tap.subscribe(onNext: { _ in
            self.viewModel!.saveKeys().subscribe(onNext: { flag in
                if flag {
                    UserDefaults.standard.set(true, forKey: "UserLoged")
                    self.present(TabBarVC(), animated: true, completion: nil)
                } else {
                    self.showAlert(title: "Error", message: "Something went wrong")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
}
