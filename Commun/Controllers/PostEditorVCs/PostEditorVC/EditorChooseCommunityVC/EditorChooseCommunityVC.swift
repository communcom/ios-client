//
//  EditorChooseCommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 11/14/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class EditorChooseCommunityVC: SubscriptionsVC {
    // MARK: - Properties
    var completion: ((ResponseAPIContentGetCommunity) -> Void)?
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    var interactor: SwipeDownInteractor?
    let chooseCommunityExplanationViewId = "choose-community"
    
    // MARK: - Subviews
    lazy var explanationView = ChooseCommunityExplanationView(tableView: tableView)
    
    // MARK: - Initializers
    init(completion: ((ResponseAPIContentGetCommunity) -> Void)?) {
        self.completion = completion
        super.init(title: "choose a community".localized().uppercaseFirst, userId: Config.currentUser?.id, type: .community)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Functions
    override func setUp() {
        super.setUp()
        
        hideFollowButton = true
        interactor = SwipeDownInteractor()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
        
        if ExplanationView.shouldShowViewWithId(chooseCommunityExplanationViewId) {
            explanationView.closeButton.addTarget(self, action: #selector(closeExplanationDidTouch), for: .touchUpInside)
            explanationView.learnMoreButton.addTarget(self, action: #selector(learnMoreExplanationDidTouch), for: .touchUpInside)
        }
    }
        
    override func modelSelected(_ item: ResponseAPIContentGetSubscriptionsItem) {
        guard let community = item.communityValue else {return}
        self.completion?(community)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3

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
    
    @objc func closeExplanationDidTouch() {
        ExplanationView.markAsShown(chooseCommunityExplanationViewId)
        tableView.tableHeaderView = nil
    }
    
    @objc func learnMoreExplanationDidTouch() {
        load(url: "https://commun.com/faq")
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension EditorChooseCommunityVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor?.hasStarted == true ? interactor : nil
    }
}
