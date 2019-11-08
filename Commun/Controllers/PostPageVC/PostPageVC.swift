////
////  PostPageVC.swift
////  Commun
////
////  Created by Chung Tran on 11/8/19.
////  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import CyberSwift
//import RxDataSources
//
//class PostPageVC: ListViewController<ResponseAPIContentGetComment> {
//    // MARK: - Subviews
//    lazy var navigationBar = PostPageNavigationBar(height: 56)
//    
//    // MARK: - Properties
//    
//    
//    // MARK: - Initializers
//    init(post: ResponseAPIContentGetPost? = nil) {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    init(permlink: String, userId: String) {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func setUp() {
//        super.setUp()
//        // navigationBar
//        view.addSubview(navigationBar)
//        navigationBar.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
//        
//        
//    }
//    
//    override func bind() {
//        super.bind()
//        observePostDeleted()
//    }
//    
//    func observePostDeleted() {
//        NotificationCenter.default.rx.notification(.init(rawValue: "\(ResponseAPIContentGetPost.self)Deleted"))
//            .subscribe(onNext: { (notification) in
//                guard let deletedPost = notification.object as? ResponseAPIContentGetPost,
//                    deletedPost.identity == (self.viewModel as! PostPageViewModel).post.value?.identity
//                    else {return}
//                self.showAlert(title: "deleted".localized().uppercaseFirst, message: "the post has been deleted".localized().uppercaseFirst, completion: { (_) in
//                    self.back()
//                })
//            })
//            .disposed(by: disposeBag)
//    }
//}
