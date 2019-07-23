//
//  PickupProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 01/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PickupAvatarVC: UIViewController, BoardingRouter {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let image = BehaviorRelay<UIImage?>(value: nil)
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var nextButton: StepButton!
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.tune(withText:          "Pick a profile picture".localized(),
                                 hexColors:         blackWhiteColorPickers,
                                 font:              UIFont.init(name: "SFProText-Bold", size: 34.0 * Config.widthRatio),
                                 alignment:         .left,
                                 isMultiLines:      true)
        }
    }
    

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup navigation
        self.title = "Pick a profile picture".localized()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // binding
        bindViews()
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
    func bindViews() {
        // bind image
        image.filter{$0 != nil}
            .bind(to: userAvatarImage.rx.image)
            .disposed(by: disposeBag)
        
        image.map {$0 != nil}
            .bind(to: chooseImageButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        image.map {$0 != nil}
            .subscribe(onNext: {hasImage in
                self.nextButton.isEnabled = hasImage
            })
            .disposed(by: disposeBag)
    }
    

    // MARK: - Actions
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
            .flatMap{ url -> Single<String> in
                // UpdateProfile without waiting for transaction
                return NetworkService.shared.updateMeta(
                    params: ["profile_image": url],
                    waitForTransaction: false
                )
                .andThen(Single<String>.just(url))
            }
            .subscribe(onSuccess: { (url) in
                do {
                    try KeychainManager.save(data: [
                        Config.settingStepKey: CurrentUserSettingStep.setBio.rawValue
                    ])
                    self.hideHud()
                    self.boardingNextStep()
                } catch {
                    self.hideHud()
                    self.showError(error)
                }
            }) {[weak self] (error) in
                self?.hideHud()
                self?.image.accept(nil)
                self?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func skipButtonDidTouch(_ sender: Any) {
        do {
            try KeychainManager.save(data: [
                Config.settingStepKey: CurrentUserSettingStep.setBio.rawValue
            ])
            boardingNextStep()
        } catch {
            showError(error)
        }
    }
}
