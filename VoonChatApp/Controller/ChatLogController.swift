//
//  ChatLogController.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/13/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title   = "Test"
        
        
        setupInputComponents()
        
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.red
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
