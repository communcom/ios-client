//
//  TLPhotosPickerViewController+Rx.swift
//  Commun
//
//  Created by Chung Tran on 22/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import TLPhotoPicker
import RxCocoa
import RxSwift

class CustomTLPhotosPickerVC: TLPhotosPickerViewController {
    
    static var singleImage: CustomTLPhotosPickerVC {
        // If updating
        let pickerVC = CustomTLPhotosPickerVC()
        var configure = TLPhotosPickerConfigure()
        configure.singleSelectedMode = true
        configure.allowedLivePhotos = false
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.mediaType = .image
        pickerVC.configure = configure
        return pickerVC
    }
    
    override func doneButtonTap() {
        self.delegate?.dismissPhotoPicker(withTLPHAssets: self.selectedAssets)
    }
    
    override func cancelButtonTap() {
        self.delegate?.dismissPhotoPicker(withTLPHAssets: [])
        self.dismiss(animated: true, completion: nil)
    }
}

extension TLPhotosPickerViewController: HasDelegate {
    public typealias Delegate = TLPhotosPickerViewControllerDelegate
}

class RxTLPhotosPickerViewControllerDelegateProxy: DelegateProxy<TLPhotosPickerViewController, TLPhotosPickerViewControllerDelegate>, DelegateProxyType, TLPhotosPickerViewControllerDelegate {
    
    public weak private(set) var pickerVC: TLPhotosPickerViewController?
    public init(pickerVC: ParentObject) {
        self.pickerVC = pickerVC
        super.init(parentObject: pickerVC, delegateProxy: RxTLPhotosPickerViewControllerDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register {RxTLPhotosPickerViewControllerDelegateProxy(pickerVC: $0)}
    }
    
    fileprivate lazy var didSelectAssets = PublishSubject<[TLPHAsset]>()
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        didSelectAssets.onNext(withTLPHAssets)
        (self.forwardToDelegate())?.dismissPhotoPicker(withTLPHAssets: withTLPHAssets)
    }
    
    deinit {
        didSelectAssets.onCompleted()
    }
}

extension Reactive where Base: TLPhotosPickerViewController {
    public var delegate: DelegateProxy<TLPhotosPickerViewController, TLPhotosPickerViewControllerDelegate> {
        return RxTLPhotosPickerViewControllerDelegateProxy.proxy(for: base)
    }
    
    var didSelectAssets: Observable<[TLPHAsset]> {
        return (delegate as! RxTLPhotosPickerViewControllerDelegateProxy).didSelectAssets
    }
}
