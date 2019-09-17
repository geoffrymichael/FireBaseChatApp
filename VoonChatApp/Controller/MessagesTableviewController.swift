//
//  MessagesTableviewController.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/10/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableviewController: UITableViewController {

    let messageCell = "messageCell"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: messageCell)
        
        fetchUser()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profiliImageUrl = dictionary["profileImageUrl"] as? String
                user.id = dictionary["id"] as? String
                
                self.users.append(user)
                
                
                self.tableView.reloadData()
                
                
            }
            
            
            
        }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCell, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        //Wow. Organically created this data pull statement myself. I will probably change it with tutorial, but it was nice I was able to do it through my own knowledge without being walked through it.
        
        cell.profileImageView.loadImagesUsingCache(url: user.profiliImageUrl, tableView: tableView)
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            if let profileImage = user.profiliImageUrl {
//                if let data = try? Data(contentsOf: URL(string: profileImage)!) {
//                    if let image = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            cell.profileImageView.image = image
//                            tableView.reloadData()
//                        }
//                    }
//                }
//            }
//        }
    
        
        
        return cell
        
    }
    
    //Reference to Messages View Controller show we can access showhatController function
    var messagesController: MessagesViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(user: user)
        }
    }

}





