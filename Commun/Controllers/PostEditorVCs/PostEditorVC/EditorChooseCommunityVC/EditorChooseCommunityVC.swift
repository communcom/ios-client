//
//  EditorChooseCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 11/14/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class EditorChooseCommunityVC: SubscriptionsVC {
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetSubscriptionsCommunity)->Void)?
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    var interactor: SwipeDownInteractor?
    
    override var tableViewMargin: UIEdgeInsets {
        return super.tableViewMargin.insetBy(top: 44)
    }
    
    // MARK: - Initializers
    init(completion: ((ResponseAPIContentGetSubscriptionsCommunity)->Void)?) {
        self.completion = completion
        super.init(title: "choose a community".localized().uppercaseFirst, userId: Config.currentUser?.id, type: .community)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        hideFollowButton = true
        view.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 20)
        
        interactor = SwipeDownInteractor()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else {
            return
        }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.cancel()
        default:
            break
        }
    }
    
    override func bindModelSelected() {
        tableView.rx.modelSelected(ResponseAPIContentGetSubscriptionsItem.self)
            .filter {$0.communityValue != nil}
            .map {$0.communityValue!}
            .filter {$0.isSubscribed == true}
            .subscribe(onNext: { (item) in
                self.completion?(item)
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension EditorChooseCommunityVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
