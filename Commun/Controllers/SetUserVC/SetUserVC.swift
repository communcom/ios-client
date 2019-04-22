//
//  SetUserVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SetUserVC: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var viewModel: SetUserViewModel?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = "Sign up"
        
        setBindings()
        makeActions()
    }

    func setBindings() {
        if let viewModel = viewModel {
            userNameTextField.rx.text.map { string -> String in
                return string ?? ""
            }.bind(to: viewModel.userName).disposed(by: disposeBag)
        }
    }
    
    func makeActions() {
        nextButton.rx.tap.subscribe(onNext: { _ in
            self.viewModel!.setUser().subscribe(onNext: { flag in
                if let vc = controllerContainer.resolve(LoadKeysVC.self) {
                    vc.viewModel = LoadKeysViewModel(nickName: self.userNameTextField.text ?? "")
                    self.present(vc, animated: true, completion: nil)
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
}
