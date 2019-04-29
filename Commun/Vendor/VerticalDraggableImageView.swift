//
//  VerticalDraggableImageView.swift
//  Commun
//
//  Created by Chung Tran on 23/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class VerticalDraggableImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(detectPan(_:)))
        self.gestureRecognizers = [pan]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(detectPan(_:)))
        self.gestureRecognizers = [pan]
    }
    
    private var lastY: CGFloat = 0
    
    private var beganLocation: CGPoint?
    
    @objc func detectPan(_ recognizer: UIPanGestureRecognizer) {
        guard image != nil else {return}
        let location = recognizer.location(in: self)
        if recognizer.state == .began {
            // Reset counter
            beganLocation = location
            return
        }
        // Count pan distance
        let distance = location.y - beganLocation!.y
        beganLocation = location
        let newLastY = lastY + distance/self.height
        
        // Check if out of bound
        if abs(newLastY*self.width) > abs(self.height/2) {return}
        lastY = newLastY
        self.layer.contentsRect = CGRect(x: 0, y: lastY, width: 1, height: 1)
    }
}
