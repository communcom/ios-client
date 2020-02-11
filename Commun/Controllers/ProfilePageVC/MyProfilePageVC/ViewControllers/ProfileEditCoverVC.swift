//
//  ProfileEditCoverVC.swift
//  Commun
//
//  Created by Chung Tran on 23/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift

class ProfileEditCoverVC: UIViewController {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    var profile = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    private let bag = DisposeBag()
    
    var didSelectImage = PublishSubject<UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Bind
        bindProfile()
        
        // Bind avatar
        avatarImage.observeCurrentUserAvatar()
            .disposed(by: bag)
    }

    func updateImage(_ image: UIImage?) {
        coverImage.image = image
        updateScrollVIew()
    }

    func updateScrollVIew() {
        guard let image = coverImage.image else {
            return
        }
        let displayWidth = UIScreen.main.bounds.width
        let proportion = image.size.width / displayWidth
        let imageHeight = image.size.height / proportion
        coverImage.frame = CGRect(x: 0, y: 0, width: displayWidth, height: imageHeight)
        imageScrollView.contentSize = coverImage.bounds.size
    }
    
    // MARK: - binding
    func bindProfile() {
        profile
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { profile in
                // user name
                self.userNameLabel.text = profile.username
                // join date
                self.joinedDateLabel.text = Formatter.joinedText(with: profile.registration?.time)
            })
            .disposed(by: bag)
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        let image = ProfileEditCoverVC.cropImage(scrollVIew: imageScrollView, imageView: coverImage, disableHorizontal: true)
        didSelectImage.onNext(image ?? coverImage.image!)
    }

    static func cropImage(scrollVIew: UIScrollView,
                          imageView: UIImageView,
                          maxSize: CGFloat = 1280,
                          disableHorizontal: Bool = false) -> UIImage? {
        guard let originalImage = imageView.image else {
            return nil
        }

        let displayWidth = scrollVIew.bounds.width
        let displayHeight = scrollVIew.bounds.height

        var proportion = originalImage.size.width < originalImage.size.height ? originalImage.size.width / displayWidth : originalImage.size.height / displayHeight

        if disableHorizontal {
            proportion = originalImage.size.width / displayWidth
        }

        proportion /= scrollVIew.zoomScale

        let offsetX = scrollVIew.contentOffset.x
        let offsetY = scrollVIew.contentOffset.y

        var finalRect = CGRect(x: offsetX,
                               y: offsetY,
                               width: displayWidth,
                               height: scrollVIew.bounds.height)
        finalRect.origin.x *= proportion
        finalRect.origin.y *= proportion
        finalRect.size.width *= proportion
        finalRect.size.height *= proportion

        // crop
        let imageRef: CGImage = (originalImage.cgImage?.cropping(to: finalRect))!
        let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)

        return image.resize(maxSize)
    }
}
