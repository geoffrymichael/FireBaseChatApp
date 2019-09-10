//
//  ViewController.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/9/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
    }

    @objc func handleLogout() {
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }

}

