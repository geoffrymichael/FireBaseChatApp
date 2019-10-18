//
//  ChatLogController.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/13/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    
    //Reference to User model so we can access it with this controller
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else { return }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                
                message.fromId = dictionary["fromId"] as? String
                message.toId = dictionary["toId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.imageUrl = dictionary["imageUrl"] as? String
                message.imageHeight = dictionary["imageHeight"] as? NSNumber
                message.imageWidth = dictionary["imageWidth"] as? NSNumber
                
                //This check is most likely deprecated since we have added a deeper node to relate user converstations
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                    
                }
                

                
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
    
        textField.delegate = self
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
    
        
        
        return textField
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        collectionView.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor.white
 
        
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        
        setupInputComponents()
        
        setupKeyboardObservers()
        
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleHideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    var keyboardIsPresent = false
    
    @objc func handleShowKeyboard(notification: NSNotification) {
        
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                
                containerBottomAnchor?.constant = -keyboardSize.height
                if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
                    UIView.animate(withDuration: duration) {
                        self.view.layoutIfNeeded()
                    }
                }
               

            }
        
    }
    
    @objc func handleHideKeyboard(notification: NSNotification) {
        
        containerBottomAnchor?.constant = 0
        if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) {
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 32
        } else if message.imageUrl != nil {
            
            cell.bubbleWidthAnchor?.constant = 200
            
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = self.user?.profiliImageUrl {
            cell.profileImageView.loadImagesUsingCache(url: profileImageUrl)
        }

      
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
        
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let textImageMessageUrl = message.imageUrl {
            cell.textImageView.loadImagesUsingCache(url: textImageMessageUrl)
            cell.textImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        } else {
            cell.textImageView.isHidden = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = CGFloat(80)
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 20
        } else if message.imageUrl != nil {
            
            if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
                height = CGFloat(imageHeight / imageWidth * 200)
                
            }
            
        }
        
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let font = UIFont.systemFont(ofSize: 16)
        
        return NSString(string: text).boundingRect(with: size, options: options , attributes: [NSAttributedString.Key.font: font], context: nil)
    }
    
    var containerBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
//        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerBottomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "picIcon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePicTap)))
        uploadImageView.isUserInteractionEnabled = true
        
        containerView.addSubview(uploadImageView)
        
        
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(inputTextField)

        inputTextField.leftAnchor.constraint(equalTo:uploadImageView.rightAnchor, constant: 10).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true


    }
    
    @objc func handlePicTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
 
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            selectedImage = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedImage = originalImage
            
        }
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message-images").child("\(imageName).png")
        
        if let image = selectedImage {
            if let uploadData = image.jpegData(compressionQuality: 0.2) {
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error as Any)
                            return
                        }
                        
                        //TODO: Finish image message configure
                        if let imageUrl = url?.absoluteString {
                            self.saveMessageWithImageUrl(url: imageUrl, image: image)
                        }
                        
                        
                    })
                }
            }
           
        }
        //        logo.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        
        
        print("I selected an image")
    }
    
    private func saveMessageWithImageUrl(url: String, image: UIImage) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        
        guard let toId = user?.id else { return }
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp: NSNumber = (Date().timeIntervalSince1970 as AnyObject as! NSNumber)
        let values = ["toId": toId as Any, "fromId": fromId as Any, "timeStamp": timeStamp, "imageUrl": url as Any, "imageHeight" : image.size.height as NSNumber, "imageWidth": image.size.width as NSNumber] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.inputTextField.text = nil
            
            let messageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId: String = childRef.key ?? "Default Error"
            
            messageRef.updateChildValues([messageId:
                1])
            
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recipientUserMessageRef.updateChildValues([messageId: 1])
            
        }
    }
    
    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        
        guard let toId = user?.id else { return }
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp: NSNumber = (Date().timeIntervalSince1970 as AnyObject as! NSNumber)
        let values = ["text": inputTextField.text! as Any, "toId": toId as Any, "fromId": fromId as Any, "timeStamp": timeStamp] as [String : Any]

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.inputTextField.text = nil
            
            let messageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId: String = childRef.key ?? "Default Error"
          
            messageRef.updateChildValues([messageId:
                1])
            
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            
            recipientUserMessageRef.updateChildValues([messageId: 1])
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
}
