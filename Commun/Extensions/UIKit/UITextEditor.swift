//
//  UITextEditor.swift
//  Commun
//
//  Created by Chung Tran on 7/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol UITextEditor: UIView {}

extension UITextField: UITextEditor {}
extension UITextView: UITextEditor {}
