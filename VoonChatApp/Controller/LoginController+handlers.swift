//
//  LoginController+handlers.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/11/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//

import UIKit

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @objc func handleLogoTap() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        
        present(picker, animated: true, completion: nil)
 
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print(5678)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            selectedImage = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedImage = originalImage
     
        }
        
        logo.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        
        
        
    }
    
    
    
    
}
