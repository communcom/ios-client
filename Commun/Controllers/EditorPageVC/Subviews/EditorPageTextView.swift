//
//  EditorPageTextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage
import CyberSwift

class EditorPageTextView: ExpandableTextView {
    // MARK: - Properties
    private let bag = DisposeBag()
    
    // MARK: - Methods
    private func attach(image: UIImage, urlString: String? = nil, description: String? = nil, at index: Int? = nil) {
        // Insert Attachment
        let attachment = textStorage.imageAttachment(from: image, urlString: urlString, description: description, into: self)
        let imageAS = NSAttributedString(attachment: attachment)
        
        if let index = index {
            textStorage.insert(imageAS, at: index)
        } else {
            textStorage.append(imageAS)
        }
        textStorage.addAttributes(typingAttributes, range: NSMakeRange(0, textStorage.length))
    }
    
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        
        // set image
        if let image = image {
            attach(image: image, urlString: urlString, description: description)
        } else if let urlString = urlString,
            let url = URL(string: urlString) {
            let textAttachment = TextAttachment()
            textAttachment.urlString    = urlString
            textAttachment.desc         = description
            insertText(textAttachment.placeholderText)
            
            let manager = SDWebImageManager.shared()
            
            manager.imageDownloader?.downloadImage(with: url, completed: {[weak self] (image, data, error, _) in
                guard let strongSelf = self else {return}
                
                // current location of placeholder
                let location = strongSelf.attributedText.nsRangeOfText(textAttachment.placeholderText).location
                
                guard location >= 0 else {return}
                
                // attach image
                if let image = image {
                    strongSelf.attach(image: image, urlString: urlString, description: description, at: location)
                    strongSelf.removeText(textAttachment.placeholderText)
                } else {
                    strongSelf.parentViewController?.showErrorWithLocalizedMessage("could not load image".localized().uppercaseFirst + "with URL".localized() + " " + urlString)
                }
            })
        } else {
            parentViewController?.showGeneralError()
        }
    }
    
    func parseText(_ text: String?) {
        let string = ###"{"id":1,"type":"post","attributes":{"version":1,"title":"Сказка про царя"},"content":[{"id":2,"type":"paragraph","content":[{"id":3,"type":"text","content":"Много лет тому назад, "},{"id":4,"type":"text","content":"Царь купил себе айпад. ","attributes":{"style":["bold","italic"],"text_color":"#ffff0000"}},{"id":5,"type":"tag","content":"с_той_поры_прошли_века","attributes":{"anchor":"favdfa9384fnakdrkdfkd"}},{"id":6,"type":"text","content":" , Люди "},{"id":7,"type":"link","content":"помнят ","attributes":{"url":"http://yandex.ru"}},{"id":8,"type":"link","content":"чудака.","attributes":{"url":"https://www.anekdot.ru/i/8/28/vina.jpg"}}]},{"id":9,"type":"image","content":"http://cartoonbank.ru/?page_id=29&brand=36","attributes":{"description":"Hi!"}},{"id":10,"type":"video","content":"https://www.youtube.com/watch?v=UiYlRkVxC_4","attributes":{"title":"Rammstein - Reise, Reise (Lyrics)","provider_name":"YouTube","author":"admiralscoat","author_url":"https://www.youtube.com/user/Bmontemoney","description":"Lyrics video Rammstein - Reise, Reise Please rate, comment and subscribe! Rammstein members: #1. Till Lindemann - Lead vocals #2. Richard Z. Kruspe - Lead gu...","thumbnail_url":"https://i.ytimg.com/vi/UiYlRkVxC_4/hqdefault.jpg","thumbnail_size":[480,360],"html":"<div><div style=\"left: 0; width: 100%; height: 0; position: relative; padding-bottom: 56.2493%;\"><iframe src=\"https://www.youtube.com/embed/UiYlRkVxC_4?feature=oembed\" style=\"border: 0; top: 0; left: 0; width: 100%; height: 100%; position: absolute;\" allowfullscreen scrolling=\"no\"></iframe></div></div>"}},{"id":11,"type":"website","content":"https://trinixy.ru","attributes":{"title":"Триникси","description":"Время знать больше","provider_name":"Яндекс","thumbnail_url":"https://yastatic.net/s3/home/logos/share/share-logo_ru.png"}},{"id":12,"type":"set","content":[{"id":13,"type":"image","content":"http://cartoonbank.ru/?page_id=29&brand=36"},{"id":14,"type":"video","content":"https://www.youtube.com/watch?v=UiYlRkVxC_4"},{"id":15,"type":"website","content":"http://yandex.ru"}]}]}"###
        
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
