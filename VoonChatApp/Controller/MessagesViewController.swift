//
//  MessagesViewController.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/9/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.title = "test"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "M", style: .plain, target: self, action: #selector(handleNewMessage))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        checkIfUserIsLoggedIn()
        
        
    }
    
    func checkIfUserIsLoggedIn() {
        //Check if user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            //This delays the selector so that too much usage is not happening
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
            saveUserAndUpdateNavTitle()
        }
    }
    
    
    func saveUserAndUpdateNavTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                
                
            }
            
        }, withCancel: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = MessagesTableviewController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }

    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logOutError {
            print(logOutError)
        }
        
        
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }

}

