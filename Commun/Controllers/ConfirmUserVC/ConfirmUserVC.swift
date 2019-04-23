//
//  ConfirmUserVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PinCodeInputView

class ConfirmUserVC: UIViewController {

    @IBOutlet weak var pinCodeView: UIView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var viewModel: ConfirmUserViewModel?
    
    let disposeBag = DisposeBag()
    
    let pinCodeInputView: PinCodeInputView<ItemView> = .init(
        digit: 4,
        itemSpacing: 12,
        itemFactory: {
            return ItemView()
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.title = "Verification"
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        pinCodeInputView.frame = pinCodeView.bounds
        pinCodeInputView.set(changeTextHandler: { text in
            print(text)
        })
        pinCodeInputView.set(
            appearance: .init(
                itemSize: CGSize(width: 48, height: 56),
                font: .init(descriptor: UIFontDescriptor(name: "SF Pro Text", size: 26), size: 26),
                textColor: .black,
                backgroundColor: UIColor(hexString: "F3F5FA")!,
                cursorColor: UIColor(red: 69/255, green: 108/255, blue: 1, alpha: 1),
                cornerRadius: 8
            )
        )
        
        pinCodeView.addSubview(pinCodeInputView)
        
        setupActions()
    }

    override func viewWillLayoutSubviews() {
        pinCodeInputView.frame = pinCodeView.bounds
    }
    
    func setupActions() {
        resendButton.rx.tap.subscribe(onNext: { _ in
            if let viewModel = self.viewModel {
                viewModel.resendCode().subscribe(onNext: { flag in
                    self.showAlert(title: "Resend code", message: flag ? "Success" : "Failed")
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
        
        nextButton.rx.tap.subscribe(onNext: { _ in
            if let viewModel = self.viewModel {
                viewModel.checkPin(self.pinCodeInputView.text).subscribe(onNext: { success in
                    // Next
                    if success {
                        if let vc = controllerContainer.resolve(SetUserVC.self) {
                            vc.viewModel = SetUserViewModel(phone: self.viewModel?.phone.value ?? "")
                            self.navigationController?.pushViewController(vc)
                        }
                    } else {
                        self.showAlert(title: "Error", message: "Incorrect code")
                    }
                    
                }).disposed(by: self.disposeBag)
            }
        }).disposed(by: disposeBag)
    }
}
