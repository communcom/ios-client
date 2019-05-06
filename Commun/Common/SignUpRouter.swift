//
//  SignUpRouter.swift
//  Commun
//
//  Created by msm72 on 5/6/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift

// MARK: - Input & Output protocols
@objc protocol SignUpRoutingLogic {
    func routeToNext(scene: String)
}

//protocol SignUpDataPassing {
//    var dataStore: SignUpDataStore? { get }
//}

class SignUpRouter: NSObject, SignUpRoutingLogic {
    // MARK: - Properties
    weak var viewController: UIViewController?
//    var dataStore: SignUpDataStore?
    
    
    // MARK: - Class Initialization
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Routing
    func routeToNext(scene: String) {
        switch scene {
        case "SignUpVC":
            self.viewController?.navigationController?.pushViewController(controllerContainer.resolve(SignUpVC.self)!)
            
        default:
            break
        }
    }
    
    
    // MARK: - Navigation
    //    func navigateToSomewhere(source: TestShowViewController, destination: SomewhereViewController) {
    //        source.show(destination, sender: nil)
    //    }
    
    
    // MARK: - Passing data
    //    func passDataToSomewhere(source: TestShowDataStore, destination: inout SomewhereDataStore) {
    //        destination.name = source.name
    //    }
}
