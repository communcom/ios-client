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
    
    // Authorization scene
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
        let vc = SignInVC.instanceController(fromStoryboard: "EditorPageVC", withIdentifier: "EditorPageVC") as! EditorPageVC
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

    // Notifications scene
    container.register(NotificationsPageVC.self, factory: { r in
        let vc = NotificationsPageVC.instanceController(fromStoryboard: "NotificationsPageVC", withIdentifier: "NotificationsPageVC") as! NotificationsPageVC
        return vc
    })
    
    return container
}()
