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
    
    container.register(FeedPageVC.self, factory: { r in
        let vc = FeedPageVC.instanceController(fromStoryboard: "FeedPageVC", withIdentifier: "FeedPageVC")
        return vc as! FeedPageVC
    })
    
    container.register(PostPageVC.self, factory: { r in
        let vc = PostPageVC.instanceController(fromStoryboard: "PostPageVC", withIdentifier: "PostPageVC") as! PostPageVC
        vc.viewModel = PostPageViewModel()
        return vc
    })
    
    return container
}()
