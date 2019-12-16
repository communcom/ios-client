//
//  CreateBioVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift

class CreateBioVC: UIViewController, BoardingRouter {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    private let charactersLimit = 180

    // MARK: - IBOutlets
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var nextButton: StepButton!
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            self.textView.placeholder = "write text placeholder".localized().uppercaseFirst
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.tune(withText: "describe yourself".localized().uppercaseFirst,
                                 hexColors: blackWhiteColorPickers,
                                 font: UIFont.init(name: "SFProText-Bold", size: 34.0 * Config.widthRatio),
                                 alignment: .left,
                                 isMultiLines: false)
        }
    }
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Custom Functions
    func bindUI() {
        // Bind textView
        let bioChanged = textView.rx.text.orEmpty
            .map {$0.count != 0}
        
        bioChanged
            .subscribe(onNext: {changed in
                self.nextButton.isEnabled = changed
            })
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.characterCountLabel.text = "\(text.count)/\(self.charactersLimit)"
            })
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .filter {$0.count > self.charactersLimit}
            .subscribe(onNext: limitCharacters())
            .disposed(by: disposeBag)
    }
    
    func limitCharacters() -> (_ newText: String) -> Void {
        return { newText in
            self.textView.text = String(newText.prefix(self.charactersLimit))
        }
    }

    // MARK: - Actions
    @IBAction func endEditing(_ sender: Any) {
        if textView.isFirstResponder {
            self.view.endEditing(true)
            return
        }
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func nextButtonDidTouch(_ sender: Any) {
        guard let bio = textView.text else {return}
        self.showIndetermineHudWithMessage("updating...".localized().uppercaseFirst)
        // UpdateProfile without waiting for transaction
        NetworkService.shared.updateMeta(params: ["about": bio], waitForTransaction: false)
            .subscribe(onCompleted: {
                self.endBoarding()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func skipButtonDidTouch(_ sender: Any) {
        endBoarding()
    }
}
