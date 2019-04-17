//
//  ProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import CyberSwift
import SDWebImage
import UIImageView_Letters

class ProfilePageVC: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var communitiesCountLabel: UILabel!
    
    let bag = DisposeBag()
    let viewModel = ProfilePageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initial state
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        tableView.isHidden = true
        
        // bind view model
        bindViewModel()
        
        // load profile
        viewModel.loadProfile()
    }
    
    func bindViewModel() {
        viewModel.profile
            .asObservable()
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: {profile in
                self.showProfile(profile)
            })
            .disposed(by: bag)
    }
    
    func showProfile(_ profile: ResponseAPIContentGetProfile) {
        self.activityIndicator.stopAnimating()
        self.tableView.isHidden = false
        
        // profile image
        if let avatarUrl = profile.personal.avatarUrl {
            userAvatarImage.sd_setImage(with: URL(string: avatarUrl)) { (_, error, _, _) in
                if (error != nil) {
                    // TODO: Placeholder image
                    self.userAvatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
                }
            }
        } else {
            // TODO: Placeholder image
            self.userAvatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
        }
        
        // user name
        userNameLabel.text = profile.username
        
        // join date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
        joinedDateLabel.text = ("Joined".localized() + " " + dateString)
        
        // count labels
        followingsCountLabel.text = "\(profile.subscriptions.userIds.count)"
        communitiesCountLabel.text = "\(profile.subscriptions.communities.count)"
        #warning("missing followers count")
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
