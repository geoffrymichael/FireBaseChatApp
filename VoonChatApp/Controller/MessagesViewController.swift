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
//                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profiliImageUrl = dictionary["profileImageUrl"] as? String
                
                self.setTitleView(user: user)
                
            
            }
            
        }, withCancel: nil)
    }
    
    
    func setTitleView(user: User) {
        let titleView = UIView()
        
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        
        let containerView = UIView()
        titleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let profileImageView = UIImageView()
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
    
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if let profileImageUrl = user.profiliImageUrl {
            profileImageView.loadImagesUsingCache(url: profileImageUrl, tableView: tableView)
        }
        
        containerView.addSubview(profileImageView)
//        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor, constant: 40).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
        
        
        titleView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(showChatController)))
        titleView.isUserInteractionEnabled = true
        
    }
    
    @objc func showChatController() {
        print("234123421341234213412")
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

