//
//  UITableView.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import ASSpinnerView
import RxCocoa
import RxSwift

// Tags for footerView
let loadingViewTag = 9999
let postLoadingFooterViewTag = 99991
let listErrorFooterViewTag = 99992

let emptyPlaceholderViewTag = 99996

let notificationsLoadingFooterViewTag = 99993
let commentLoadingFooterViewTag = 99994
let commentEmptyFooterViewTag   = 99995

extension UITableView {
    func addLoadingFooterView() {
        // Prevent dupplicating
        if tableFooterView?.tag == loadingViewTag {
            return
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 60))
        containerView.tag = loadingViewTag
        let spinnerView = ASSpinnerView()
        spinnerView.spinnerLineWidth = 4
        spinnerView.spinnerDuration = 0.3
        spinnerView.spinnerStrokeColor = #colorLiteral(red: 0.4784313725, green: 0.6470588235, blue: 0.8980392157, alpha: 1)
        containerView.addSubview(spinnerView)
        
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        containerView.bringSubviewToFront(spinnerView)
        
        self.tableFooterView = containerView
    }
    
    func addPostLoadingFooterView() {
        // Prevent dupplicating
        if tableFooterView?.tag == postLoadingFooterViewTag {
            return
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 352))
        containerView.tag = postLoadingFooterViewTag
        let placeholderPostCell = PlaceholderPostCell(frame: CGRect(x: 0, y: 0, width: self.width, height: 352))
        containerView.addSubview(placeholderPostCell)

        placeholderPostCell.translatesAutoresizingMaskIntoConstraints = false
        placeholderPostCell.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        placeholderPostCell.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        placeholderPostCell.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: 0).isActive = true
        placeholderPostCell.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: 0).isActive = true

        self.tableFooterView = containerView
    }
    
    func addNotificationsLoadingFooterView() {
        addLoadingFooterView(
            rowType: PlaceholderNotificationCell.self,
            tag: notificationsLoadingFooterViewTag,
            rowHeight: 88,
            numberOfRows: 2
        )
    }
    
    func addLoadingFooterView<T: UIView>(rowType: T.Type, tag: Int, rowHeight: CGFloat, numberOfRows: Int = 5) {
        // Prevent dupplicating
        if tableFooterView?.tag == tag {
            return
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: rowHeight*CGFloat(numberOfRows)))
        containerView.tag = tag
        
        for i in 0..<numberOfRows {
            let placeholderView = T.init(frame: CGRect(x: 0, y: 0, width: self.width, height: rowHeight))
            placeholderView.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(placeholderView)
            
            placeholderView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CGFloat(i)*rowHeight).isActive = true
            placeholderView.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
            placeholderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            placeholderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        }
        
        self.tableFooterView = containerView
    }
    
    var numberOfRowsInTotal: Int {
        var result = 0
        for i in 0..<numberOfSections {
            result += numberOfRows(inSection: i)
        }
        return result
    }
    
    func addListErrorFooterView(with buttonHandler: Selector? = nil, on target: AnyObject) {
        // Prevent dupplicating
        if tableFooterView?.tag == listErrorFooterViewTag {
            return
        }
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 44))
        containerView.tag = listErrorFooterViewTag
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = NSMutableAttributedString().normal("can not fetch next items".localized().uppercaseFirst)
            .normal(". ")
            .bold("try again".localized().uppercaseFirst)
            .bold("?")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        containerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        if let selector = buttonHandler {
            let tap = UITapGestureRecognizer(target: target, action: selector)
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
        }
        
        self.tableFooterView = containerView
    }
    
    /// Reactive wrapper for `UITableView.insertRows(at:with:)`
    var insertRowsEvent: ControlEvent<[IndexPath]> {
        let source = rx.methodInvoked(#selector(UITableView.insertRows(at:with:)))
            .map { a in
                return a[0] as! [IndexPath]
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `UITableView.endUpdates()`
    var endUpdatesEvent: ControlEvent<Bool> {
        let source = rx.methodInvoked(#selector(UITableView.endUpdates))
            .map { _ in
                return true
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for when the `UITableView` inserted rows and ended its updates.
    var insertedItems: ControlEvent<[IndexPath]> {
        let insertEnded = Observable.combineLatest(
            insertRowsEvent.asObservable(),
            endUpdatesEvent.asObservable(),
            resultSelector: { (insertedRows: $0, endUpdates: $1) }
        )
        let source = insertEnded.map { $0.insertedRows }
        return ControlEvent(events: source)
    }
    
    func addEmptyPlaceholderFooterView(emoji: String? = nil, title: String, description: String? = nil, buttonLabel: String? = nil, buttonAction: (() -> Void)? = nil) {
        // Prevent dupplicating
        if tableFooterView?.tag == emptyPlaceholderViewTag {
            return
        }
        
        let height: CGFloat = .adaptive(height: buttonLabel == nil ? 153.0 : 203.0)
        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: height))
        let placeholderView = MyEmptyPlaceHolderView(emoji: emoji, title: title, description: description, buttonLabel: buttonLabel, buttonAction: buttonAction)
        containerView.addSubview(placeholderView)
        containerView.tag = tag
        containerView.layer.cornerRadius = CGFloat.adaptive(width: 10.0)
        containerView.clipsToBounds = true

        placeholderView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(horizontal: .adaptive(width: 10.0),
                                                                        vertical: .adaptive(height: 20.0)))

        self.tableFooterView = containerView
    }

    func addLoadMoreAction(_ loadMoreAction: @escaping (() -> Void)) -> Disposable {
        rx.didEndDecelerating
            .filter {_ in self.contentOffset.y > 0}
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self, let lastCell = strongSelf.visibleCells.last, let indexPath = strongSelf.indexPath(for: lastCell) else { return }
                
                if strongSelf.numberOfSections == 0 { return }
                
                if indexPath.row >= strongSelf.numberOfRows(inSection: strongSelf.numberOfSections - 1) - 5 {
                    loadMoreAction()
                }
            })
    }
}

extension Reactive where Base: UITableView {
    /// Reactive wrapper for `UITableView.insertRows(at:with:)`
    var insertRowsEvent: ControlEvent<[IndexPath]> {
        let source = methodInvoked(#selector(UITableView.insertRows(at:with:)))
                .map { a in
                    return a[0] as! [IndexPath]
                }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UITableView.endUpdates()`
    var endUpdatesEvent: ControlEvent<Bool> {
        let source = methodInvoked(#selector(UITableView.endUpdates))
                .map { _ in
                    return true
                }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for when the `UITableView` inserted rows and ended its updates.
    var insertedItems: ControlEvent<[IndexPath]> {
        let insertEnded = Observable.combineLatest(
                insertRowsEvent.asObservable(),
                endUpdatesEvent.asObservable(),
                resultSelector: { (insertedRows: $0, endUpdates: $1) }
        )
        
        let source = insertEnded.map { $0.insertedRows }
        
        return ControlEvent(events: source)
    }
}
