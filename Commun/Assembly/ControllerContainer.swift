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
    
    // Profile scene
    container.register(ProfileChooseAvatarVC.self, factory: { _ in
        let vc = ProfileChooseAvatarVC.instanceController(fromStoryboard: "ProfilePageVC", withIdentifier: "ProfileChooseAvatarVC") as! ProfileChooseAvatarVC
        return vc
    })

    return container
}()
