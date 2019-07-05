//
//  CreateBioVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift

class CreateBioVC: UIViewController, SignUpRouter {
    let disposeBag = DisposeBag()
    @IBOutlet weak var textView: ExpandableTextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    private let charactersLimit = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindUI()
    }
    
    func bindUI() {
        // Bind textView
        let bioChanged = textView.rx.text.orEmpty
            .map {$0.count != 0}
        
        bioChanged
            .subscribe(onNext: {changed in
                self.nextButton.isEnabled = changed
                self.nextButton.backgroundColor = changed ? #colorLiteral(red: 0.4173236787, green: 0.5017360449, blue: 0.9592832923, alpha: 1) : #colorLiteral(red: 0.7063884139, green: 0.749147296, blue: 0.9795948863, alpha: 1)
            })
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .subscribe(onNext: {text in
                self.characterCountLabel.text = "\(text.count)/100"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func nextButtonDidTouch(_ sender: Any) {
        guard let bio = textView.text else {return}
        self.showIndetermineHudWithMessage("Updating...".localized())
        NetworkService.shared.updateMeta(params: ["about": bio])
            .subscribe(onCompleted: {
                self.hideHud()
                self.endSigningUp()
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func skipButtonDidTouch(_ sender: Any) {
        endSigningUp()
    }
}
