//
//  ControllerContainer.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import Swinject

let controllerContainer: Container = {
    let container = Container()
    
    // Splash scene
    container.register(SplashViewController.self, factory: { r in
        let vc = SplashViewController.instanceController(fromStoryboard: "Main", withIdentifier: "SplashViewController") as! SplashViewController
        return vc
    })
    
    // Welcome scene
    container.register(WelcomeVC.self, factory: { r in
        let vc = WelcomeVC.instanceController(fromStoryboard: "WelcomeVC", withIdentifier: "WelcomeVC") as! WelcomeVC
        return vc
    })
    
    container.register(WelcomeItemVC.self, factory: { r in
        let vc = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
        return vc
    })
    
    // Authorization scene
    container.register(SignInViewController.self, factory: { r in
        let vc = SignInViewController.instanceController(fromStoryboard: "SignInViewController", withIdentifier: "SignInViewController") as! SignInViewController
        return vc
    })

    container.register(SignUpVC.self, factory: { r in
        let vc = SignUpVC.instanceController(fromStoryboard: "SignUpVC", withIdentifier: "SignUpVC") as! SignUpVC
        return vc
    })
    
    container.register(SelectCountryVC.self, factory: { r in
        let vc = SelectCountryVC.instanceController(fromStoryboard: "SelectCountryVC", withIdentifier: "SelectCountryVC") as! SelectCountryVC
        return vc
    })
    
    container.register(SetUserVC.self, factory: { r in
        let vc = SetUserVC.instanceController(fromStoryboard: "SetUserVC", withIdentifier: "SetUserVC") as! SetUserVC
        return vc
    })
    
    container.register(ConfirmUserVC.self, factory: { r in
        let vc = ConfirmUserVC.instanceController(fromStoryboard: "ConfirmUserVC", withIdentifier: "ConfirmUserVC") as! ConfirmUserVC
        return vc
    })
    
    container.register(BoardingVC.self, factory: { r in
        let vc = BoardingVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "BoardingVC") as! BoardingVC
        return vc
    })
    
    container.register(EnableBiometricsVC.self, factory: {r in
        let vc = EnableBiometricsVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "EnableBiometricsVC") as! EnableBiometricsVC
        return vc
    })
    
    container.register(KeysVC.self, factory: {r in
        let vc = KeysVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "KeysVC") as! KeysVC
        return vc
    })
    
    container.register(PickupAvatarVC.self, factory: { r in
        let vc = PickupAvatarVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "PickupAvatarVC") as! PickupAvatarVC
        return vc
    })
    
    container.register(CreateBioVC.self, factory: { r in
        let vc = CreateBioVC.instanceController(fromStoryboard: "Boarding", withIdentifier: "CreateBioVC") as! CreateBioVC
        return vc
    })
    
    // TabBar
    container.register(TabBarVC.self, factory: { r in
        let vc = TabBarVC()
        return vc
    })
    
    // Feed scene
    container.register(FeedPageVC.self, factory: { r in
        let vc = FeedPageVC.instanceController(fromStoryboard: "FeedPageVC", withIdentifier: "FeedPageVC")
        return vc as! FeedPageVC
    })
    
    container.register(PostPageVC.self, factory: { r in
        let vc = PostPageVC.instanceController(fromStoryboard: "PostPageVC", withIdentifier: "PostPageVC") as! PostPageVC
        vc.viewModel = PostPageViewModel()
        return vc
    })
    
    container.register(EditorPageVC.self, factory: { r in
        let vc = EditorPageVC.instanceController(fromStoryboard: "EditorPageVC", withIdentifier: "EditorPageVC") as! EditorPageVC
        return vc
    })
    
    // Profile scene
    container.register(ProfilePageVC.self, factory: { r in
        let vc = ProfilePageVC.instanceController(fromStoryboard: "ProfilePageVC", withIdentifier: "ProfilePageVC") as! ProfilePageVC
        return vc
    })
    
    container.register(ProfileEditCoverVC.self, factory: { r in
        let vc = ProfileEditCoverVC.instanceController(fromStoryboard: "ProfilePageVC", withIdentifier: "ProfileEditCoverVC") as! ProfileEditCoverVC
        return vc
    })
    
    container.register(ProfileChooseAvatarVC.self, factory: { r in
        let vc = ProfileChooseAvatarVC.instanceController(fromStoryboard: "ProfilePageVC", withIdentifier: "ProfileChooseAvatarVC") as! ProfileChooseAvatarVC
        return vc
    })
    
    container.register(ProfileEditBioVC.self, factory: { r in
        let vc = ProfileEditBioVC.instanceController(fromStoryboard: "ProfilePageVC", withIdentifier: "ProfileEditBioVC") as! ProfileEditBioVC
        return vc
    })
    
    container.register(SettingsVC.self, factory: { r in
        let vc = SettingsVC.instanceController(fromStoryboard: "SettingsVC", withIdentifier: "SettingsVC") as! SettingsVC
        return vc
    })
    
    container.register(LanguageVC.self, factory: { r in
        let vc = LanguageVC.instanceController(fromStoryboard: "LanguageVC", withIdentifier: "LanguageVC") as! LanguageVC
        return vc
    })

    // Notifications scene
    container.register(NotificationsPageVC.self, factory: { r in
        let vc = NotificationsPageVC.instanceController(fromStoryboard: "NotificationsPageVC", withIdentifier: "NotificationsPageVC") as! NotificationsPageVC
        return vc
    })
    
    return container
}()
