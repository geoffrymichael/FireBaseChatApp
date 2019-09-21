//
//  ChatMessageCell.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/20/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "place holder"
        tv.font = UIFont.systemFont(ofSize: 16)
        
        return tv
 
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textView)
        
        
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
