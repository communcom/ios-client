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

class PickupAvatarVC: UIViewController, SignUpRouter {
    let disposeBag = DisposeBag()
    @IBOutlet weak var userAvatarImage: UIImageView!
    
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
        
    }
    
    @IBAction func chooseAvatarButtonDidTouch(_ sender: Any) {
        // Save image for reversing when update failed
        let originalImage = self.userAvatarImage.image
        
        // On updating
        let chooseAvatarVC = controllerContainer.resolve(ProfileChooseAvatarVC.self)!
        self.present(chooseAvatarVC, animated: true, completion: nil)
        
        chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            // Upload image
            .flatMap { image -> Single<String> in
                self.userAvatarImage.image = image
                return NetworkService.shared.uploadImage(image)
            }
            // Save to db
            .flatMap {NetworkService.shared.updateMeta(params: ["profile_image": $0])}
            // Catch error and reverse image
            .subscribe(onError: {[weak self] error in
                self?.userAvatarImage.image = originalImage
                self?.showGeneralError()
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func nextButtonDidTouch(_ sender: Any) {
        do {
            try KeychainManager.save(data: [
                Config.registrationStepKey: CurrentUserRegistrationStep.setBio.rawValue
            ])
            signUpNextStep()
        } catch {
            showError(error)
        }
        
    }
    
    @IBAction func skipButtonDidTouch(_ sender: Any) {
        endSigningUp()
    }
}
