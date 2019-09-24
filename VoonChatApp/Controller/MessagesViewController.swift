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
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.navigationItem.title = "test"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "M", style: .plain, target: self, action: #selector(handleNewMessage))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        checkIfUserIsLoggedIn()
        
//        observeMessages()
        
//        observerUserMessages()
        
    }
    
    
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    
    func observerUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
           
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                //Below we create a dictionary so that messages can be grouped by who they are from. Then we s
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.fromId = dictionary["fromId"] as? String
                    message.text = dictionary["text"] as? String
                    message.timeStamp = dictionary["timeStamp"] as? NSNumber
                    message.toId = dictionary["toId"] as? String
                    
                    
                    //Sorting messages by timestamp
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        
                        
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
                        })
                    }
                    
                    
                    
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }, withCancel: nil)
        
        
        }, withCancel: nil)
        
    }
    
    
//    func observeMessages() {
//        let ref = Database.database().reference().child("messages")
//        ref.observe(.childAdded, with: { (snapshot) in
//        
//            
//            //Below we create a dictionary so that messages can be grouped by who they are from. Then we s
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let message = Message()
//                message.fromId = dictionary["fromId"] as? String
//                message.text = dictionary["text"] as? String
//                message.timeStamp = dictionary["timeStamp"] as? NSNumber
//                message.toId = dictionary["toId"] as? String
//
//                
//                //Sorting messages by timestamp
//                if let toId = message.toId {
//                    self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    
//                    
//                    self.messages.sort(by: { (message1, message2) -> Bool in
//                       return message1.timeStamp!.intValue > message2.timeStamp!.intValue
//                    })
//                }
//                
//                
//                
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//            
//            
//            
//        }, withCancel: nil)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        
        cell.message = message
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        print(indexPath.row)
        
        guard let id = message.chatPartnerId() else { return }
        
        let ref = Database.database().reference().child("users").child(id)
        
        ref.observe(.value, with: { (snapshot) in
            let dictionary = snapshot.value as! [String: AnyObject]
            
            let user = User()
            
            user.email = dictionary["email"] as? String
            user.id = id 
            user.name = dictionary["name"] as? String
            user.profiliImageUrl = dictionary["profileImageUrl"] as? String
            
            self.showChatController(user: user)
            
            
        }, withCancel: nil)
        
//        showChatController(user: User)
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
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.id = snapshot.key
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profiliImageUrl = dictionary["profileImageUrl"] as? String
                
                self.setTitleView(user: user)
                
                
            }
        }
//        
    }
    
    
    func setTitleView(user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observerUserMessages()
        
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
        
        
//        self.navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        

        
        
    }
    
    @objc func showChatController(user: User) {
        let chatlogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        chatlogController.user = user
        navigationController?.pushViewController(chatlogController, animated: true)
        
        
    }
    
    @objc func handleNewMessage() {
        let newMessageController = MessagesTableviewController()
        
        //Declaring ourselves as a message controller so that it is not nil when called in our tabelview controller
        newMessageController.messagesController = self
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

