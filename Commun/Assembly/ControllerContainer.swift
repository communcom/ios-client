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
    
    container.register(TabBarVC.self, factory: { r in
        let vc = TabBarVC()
        return vc
    })
    
    container.register(FeedPageVC.self, factory: { r in
        let vc = FeedPageVC.instanceController(fromStoryboard: "FeedPageVC", withIdentifier: "FeedPageVC")
        return vc as! FeedPageVC
    })
    
    container.register(PostPageVC.self, factory: { r in
        let vc = PostPageVC.instanceController(fromStoryboard: "PostPageVC", withIdentifier: "PostPageVC") as! PostPageVC
        vc.viewModel = PostPageViewModel()
        return vc
    })
    
    container.register(WelcomeScreenVC.self, factory: { r in
        let vc = WelcomeScreenVC.instanceController(fromStoryboard: "WelcomeScreenVC", withIdentifier: "WelcomeScreenVC") as! WelcomeScreenVC
        return vc
    })
    
    container.register(WelcomeItemVC.self, factory: { r in
        let vc = WelcomeItemVC.instanceController(fromStoryboard: "WelcomeItemVC", withIdentifier: "WelcomeItemVC") as! WelcomeItemVC
        return vc
    })
    
    container.register(SignInVC.self, factory: { r in
        let vc = SignInVC.instanceController(fromStoryboard: "SignInVC", withIdentifier: "SignInVC") as! SignInVC
        return vc
    })
    
    container.register(EditorPageVC.self, factory: { r in
        let vc = SignInVC.instanceController(fromStoryboard: "EditorPageVC", withIdentifier: "EditorPageVC") as! EditorPageVC
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
    
    container.register(ConfirmUserVC.self, factory: { r in
        let vc = ConfirmUserVC.instanceController(fromStoryboard: "ConfirmUserVC", withIdentifier: "ConfirmUserVC") as! ConfirmUserVC
        return vc
    })
    
    container.register(SetUserVC.self, factory: { r in
        let vc = SetUserVC.instanceController(fromStoryboard: "SetUserVC", withIdentifier: "SetUserVC") as! SetUserVC
        return vc
    })
    
    container.register(LoadKeysVC.self, factory: { r in
        let vc = LoadKeysVC.instanceController(fromStoryboard: "LoadKeysVC", withIdentifier: "LoadKeysVC") as! LoadKeysVC
        return vc
    })
    
    return container
}()
