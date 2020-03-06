//
//  ControllerContainer.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import Swinject

let controllerContainer: Container = {
    let container = Container()
    
    // Splash scene
    container.register(SplashViewController.self, factory: { _ in
        let vc = SplashViewController.instanceController(fromStoryboard: "Main", withIdentifier: "SplashViewController") as! SplashViewController
        return vc
    })
    
    // Welcome scene
    container.register(WelcomeVC.self, factory: { _ in
        let vc = WelcomeVC.instanceController(fromStoryboard: "WelcomeVC", withIdentifier: "WelcomeVC") as! WelcomeVC
        return vc
    })
    
    container.register(WelcomeItemVC.self, factory: { _ in
        let vc = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
        return vc
    })
    
    // Authorization scene
    container.register(SignUpVC.self, factory: { _ in
        let vc = SignUpVC.instanceController(fromStoryboard: "SignUpVC", withIdentifier: "SignUpVC") as! SignUpVC
        return vc
    })
    
    container.register(SelectCountryVC.self, factory: { _ in
        let vc = SelectCountryVC.instanceController(fromStoryboard: "SelectCountryVC", withIdentifier: "SelectCountryVC") as! SelectCountryVC
        return vc
    })
    
    container.register(ConfirmUserVC.self, factory: { _ in
        let vc = ConfirmUserVC.instanceController(fromStoryboard: "ConfirmUserVC", withIdentifier: "ConfirmUserVC") as! ConfirmUserVC
        return vc
    })
    
    container.register(BoardingVC.self, factory: { _ in
        let vc = BoardingVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "BoardingVC") as! BoardingVC
        return vc
    })
    
    container.register(EnableBiometricsVC.self, factory: {_ in
        let vc = EnableBiometricsVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "EnableBiometricsVC") as! EnableBiometricsVC
        return vc
    })
    
    container.register(KeysVC.self, factory: {_ in
        let vc = KeysVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "KeysVC") as! KeysVC
        return vc
    })
    
    container.register(PickupAvatarVC.self, factory: { _ in
        let vc = PickupAvatarVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "PickupAvatarVC") as! PickupAvatarVC
        return vc
    })
    
    container.register(CreateBioVC.self, factory: { _ in
        let vc = CreateBioVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "CreateBioVC") as! CreateBioVC
        return vc
    })
    
    // Profile scene
    container.register(ProfileEditCoverVC.self, factory: { _ in
        let vc = ProfileEditCoverVC.instanceController(fromStoryboard: "ProfilePageVC", withIdentifier: "ProfileEditCoverVC") as! ProfileEditCoverVC
        return vc
    })
    
    container.register(ProfileChooseAvatarVC.self, factory: { _ in
        let vc = ProfileChooseAvatarVC.instanceController(fromStoryboard: "ProfilePageVC", withIdentifier: "ProfileChooseAvatarVC") as! ProfileChooseAvatarVC
        return vc
    })
    
    container.register(LanguageVC.self, factory: { _ in
        let vc = LanguageVC.instanceController(fromStoryboard: "LanguageVC", withIdentifier: "LanguageVC") as! LanguageVC
        return vc
    })
    
    // ProfileEdit scene
    container.register(ProfileEditViewController.self, factory: { _ in
        let vc = ProfileEditViewController.instanceController(fromStoryboard: "ProfileEdit", withIdentifier: "ProfileEditVC") as! ProfileEditViewController
        return vc
    })

    return container
}()
