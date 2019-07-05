//
//  PickupProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import RxCocoa

class PickupAvatarVC: UIViewController, SignUpRouter {
    let disposeBag = DisposeBag()
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    let image = BehaviorRelay<UIImage?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // binding
        bindViews()
    }
    
    func bindViews() {
        // bind image
        image.filter{$0 != nil}
            .bind(to: userAvatarImage.rx.image)
            .disposed(by: disposeBag)
        
        image.map {$0 != nil}
            .bind(to: chooseImageButton.rx.isHidden)
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func chooseAvatarButtonDidTouch(_ sender: Any) {
        // On updating
        let chooseAvatarVC = controllerContainer.resolve(ProfileChooseAvatarVC.self)!
        self.present(chooseAvatarVC, animated: true, completion: nil)
        
        chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            .bind(to: self.image)
            .disposed(by: disposeBag)
    }
    
    @IBAction func nextButtonDidTouch(_ sender: Any) {
        guard let image = image.value else {return}
        // Save image for reversing when update failed
        self.showIndetermineHudWithMessage("Uploading...".localized())
        NetworkService.shared.uploadImage(image)
            // Save to bc
            .flatMapCompletable{
                NetworkService.shared.updateMeta(params: ["profile_image": $0])
            }
            // Catch error and reverse image
            .subscribe(
                onCompleted: {
                    do {
                        try KeychainManager.save(data: [
                            Config.registrationStepKey: CurrentUserRegistrationStep.setBio.rawValue
                            ])
                        self.hideHud()
                        self.signUpNextStep()
                    } catch {
                        self.hideHud()
                        self.showError(error)
                    }
                },
                onError: {[weak self] error in
                    self?.hideHud()
                    self?.image.accept(nil)
                    self?.showError(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    @IBAction func skipButtonDidTouch(_ sender: Any) {
        endSigningUp()
    }
}
