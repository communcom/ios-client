//
//  ProfileChooseAvatarVC.swift
//  Commun
//
//  Created by Chung Tran on 24/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift
import Photos
import PhotosUI

class ProfileChooseAvatarVC: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarScrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var requestAccessButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var viewModel = ProfileChooseAvatarViewModel()
    private let bag = DisposeBag()
    var currentAsset: PHAsset?
    
    private let itemsInARow: CGFloat = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        // CollectionView
        collectionView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layoutForCollectionView()

        // device rotation
        NotificationCenter.default.rx.notification(Notification.Name("UIDeviceOrientationDidChangeNotification"))
            .subscribe(onNext: { [weak self] (_) in
                guard let strongSelf = self else {return}
                strongSelf.collectionView.collectionViewLayout = strongSelf.layoutForCollectionView()
            })
            .disposed(by: bag)

        // Bind views
        bindUI()
    }
    
    func bindUI() {
        // bind avatar
        if let urlString = ResponseAPIContentGetProfile.current?.avatarUrl,
            let url = URL(string: urlString)
        {
            avatarImageView.sd_setImage(with: url, completed: nil)
        } else {
            viewModel.phAssets
                .filter {$0.count > 0}
                .take(1)
                .asSingle()
                .subscribe(onSuccess: { (assets) in
                    guard let asset = assets.first else {return}
                    self.currentAsset = asset
                    self.loadImage(with: asset) { [weak self] (image) in
                        self?.updateImage(image)
                    }
                })
                .disposed(by: bag)
        }
        
        // request permission
        viewModel.authorizationStatus
            .bind { status in
                switch status {
                case .authorized:
                    self.requestAccessButton.isHidden = true
                    self.collectionView.isHidden = false
                    self.viewModel.fetchAllImage()
                default:
                    self.requestAccessButton.isHidden = false
                    self.collectionView.isHidden = true
                }
            }
            .disposed(by: bag)
        
        // request button
        requestAccessButton.rx.action = viewModel.onRequestPermission()
        
        // bind assets to collectionView
        viewModel.phAssets
            .bind(to: collectionView.rx.items(
                cellIdentifier: "PhotoLibraryCell",
                cellType: PhotoLibraryCell.self)) { _, asset, cell in
                cell.setUp(with: asset)
            }
            .disposed(by: bag)
        
        // item selected
        self.collectionView.rx.modelSelected(PHAsset.self)
            .subscribe(onNext: {asset in
                self.currentAsset = asset
                self.loadImage(with: asset) { [weak self] (image) in
                    self?.updateImage(image)
                }
            })
            .disposed(by: bag)
        
        // bind button
        doneButton.rx.action = viewModel.onSelected(with: self.avatarScrollView, imageView: avatarImageView)
        cancelButton.rx.action = viewModel.onCancel()
        
        // dismiss
        viewModel.didSelectImage
            .subscribe(onNext: {_ in
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }

    private func loadImage(with asset: PHAsset?, completion: @escaping (UIImage?) -> Void) {
        guard let asset = asset else { return }
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.deliveryMode = .opportunistic
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true

        avatarScrollView.showLoading(cover: false, spinnerColor: .appWhiteColor)
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) { [weak self] (image, info) in
            if asset != self?.currentAsset {return}
            let degraded = info?[PHImageResultIsDegradedKey] as? NSNumber

            if degraded != nil && !degraded!.boolValue {
                self?.avatarScrollView.hideLoading()
            }
            completion(image)
        }
    }

    func updateImage(_ image: UIImage?) {
        avatarImageView.image = image
        updateScrollVIew()
    }

    private func updateScrollVIew() {
        guard let image = avatarImageView.image else {
            return
        }
        let displayWidth = UIScreen.main.bounds.width

        let proportion = image.size.width < image.size.height ? image.size.width / displayWidth : image.size.height / displayWidth
        let imageHeight = image.size.height / proportion
        let imageWidth = image.size.width / proportion

        avatarImageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        avatarScrollView.contentSize = avatarImageView.bounds.size
    }
    
    func layoutForCollectionView() -> UICollectionViewFlowLayout {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 1
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInsetReference = .fromSafeArea
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        let width = ((screenWidth - ((itemsInARow + 1) * spacing)) / itemsInARow).rounded(.down)
        layout.itemSize = CGSize(width: width, height: width)

        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        return layout
    }
}

extension ProfileChooseAvatarVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return avatarImageView
    }
}
