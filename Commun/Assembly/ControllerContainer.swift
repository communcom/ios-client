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
    container.register(BoardingVC.self, factory: { _ in
        let vc = BoardingVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "BoardingVC") as! BoardingVC
        return vc
    })
    
    container.register(EnableBiometricsVC.self, factory: {_ in
        let vc = EnableBiometricsVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "EnableBiometricsVC") as! EnableBiometricsVC
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
