//
//  EditorPageTextView+Actions.swift
//  Commun
//
//  Created by Chung Tran on 9/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorPageTextView {
    // MARK: - Methods
    private func attach(image: UIImage, urlString: String? = nil, description: String? = nil) {
        // Insert Attachment
        let attachment = textStorage.imageAttachment(from: image, urlString: urlString, description: description, into: self)
        let imageAS = NSAttributedString(attachment: attachment)
        
        // insert
        if var selectedTextRange = selectedTextRange {
            var location = offset(from: beginningOfDocument, to: selectedTextRange.start)
            
            // insert an endline character
            if location > 0,
                textStorage.attributedSubstring(from: NSMakeRange(location - 1, 1)).string != "\n" {
                textStorage.insert(NSAttributedString.separator, at: location)
                location += 1
                
                let newStart = position(from: selectedTextRange.start, offset: 1)!
                let newEnd = position(from: selectedTextRange.end, offset: 1)!
                selectedTextRange = textRange(from: newStart, to: newEnd)!
            }
            
            replace(selectedTextRange, withText: "")
            location = offset(from: beginningOfDocument, to: selectedTextRange.start)
            textStorage.insert(imageAS, at: location)
            textStorage.insert(NSAttributedString.separator, at: location+1)
        }
            // append
        else {
            textStorage.append(NSAttributedString.separator)
            textStorage.append(imageAS)
            textStorage.addAttributes(typingAttributes, range: NSMakeRange(textStorage.length - 1, 1))
        }
    }
    
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        
        // set image
        if let image = image {
            attach(image: image, urlString: urlString, description: description)
        } else if let urlString = urlString,
            let url = URL(string: urlString) {
            
            NetworkService.shared.downloadImage(url)
                .do(onSubscribe: {
                    self.parentViewController?.navigationController?
                        .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
                })
                .catchErrorJustReturn(UIImage(named: "image-not-available")!)
                .subscribe(
                    onSuccess: { [weak self] (image) in
                        guard let strongSelf = self else {return}
                        strongSelf.parentViewController?.navigationController?.hideHud()
                        strongSelf.attach(image: image, urlString: urlString, description: description)
                    },
                    onError: {[weak self] error in
                        self?.parentViewController?.navigationController?.hideHud()
                        self?.parentViewController?.showError(error)
                    }
                )
                .disposed(by: bag)
        } else {
            parentViewController?.showGeneralError()
        }
    }
    
    func parseText(_ text: String?) {
        let string = ###"{"id":1,"content":[{"id":2,"type":"paragraph","content":[{"id":3,"content":"Много лет ","type":"text","attributes":{}}]},{"id":4,"content":"https:\/\/img.golos.io\/images\/43KTyjpe2GKAtK3L3eQGLwTg3UKi.png","type":"image","attributes":{"description":"waterfall"}},{"id":5,"type":"paragraph","content":[{"id":6,"content":" назад, ","type":"text","attributes":{}},{"id":7,"content":"Царь купил себе айпад. ","type":"text","attributes":{"style":["bold","italic"],"text_color":"#FF0000"}},{"id":8,"content":"с_той_поры_прошли_века","type":"tag","attributes":{"anchor":"favdfa9384fnakdrkdfkd"}},{"id":9,"content":" , Люди ","type":"text","attributes":{}},{"id":10,"content":"помнят ","type":"link","attributes":{"url":"http:\/\/yandex.ru"}},{"id":11,"content":"чудака.","type":"link","attributes":{"url":"https:\/\/www.anekdot.ru\/i\/8\/28\/vina.jpg"}}]},{"id":12,"content":"http:\/\/cartoonbank.ru\/?page_id=29&brand=36","type":"image","attributes":{"description":"Hi!"}},{"id":13,"content":"https:\/\/www.youtube.com\/watch?v=UiYlRkVxC_4","type":"video","attributes":{}},{"id":14,"content":"https:\/\/trinixy.ru","type":"website","attributes":{}},{"id":15,"content":"http:\/\/cartoonbank.ru\/?page_id=29&brand=36","type":"image","attributes":{"description":""}},{"id":16,"content":"https:\/\/www.youtube.com\/watch?v=UiYlRkVxC_4","type":"video","attributes":{}},{"id":17,"content":"http:\/\/yandex.ru","type":"website","attributes":{}},{"id":18,"type":"paragraph","content":[]},{"id":19,"type":"paragraph","content":[]}],"type":"post","attributes":{"version":1}}"###
        
        // Parse data
        let jsonData = string.data(using: .utf8)!
        let block = try! JSONDecoder().decode(ContentBlock.self, from: jsonData)
        let attributedText = block.toAttributedString(currentAttributes: typingAttributes)
        
        // Asign raw value first
        self.attributedText = attributedText
        
        // Parse medias
        self.textStorage.parseContent(into: self)
            .do(onSubscribe: {
                self.parentViewController?.navigationController?
                    .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            })
            .subscribe(onCompleted: { [weak self] in
                self?.parentViewController?.navigationController?.hideHud()
            }) { [weak self] (error) in
                self?.parentViewController?.navigationController?.showError(error)
            }
            .disposed(by: bag)
    }
}
