//
//  Extensions.swift
//  VoonChatApp
//
//  Created by Geoffry Gambling on 9/13/19.
//  Copyright © 2019 Geoffry Gambling. All rights reserved.
//



import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    
    func loadImagesUsingCache(url: String?, tableView: UITableView) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let profileImage = url {
                if let data = try? Data(contentsOf: URL(string: profileImage)!) {
                    if let downloadedImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageCache.setObject(downloadedImage, forKey: url as AnyObject)
                            self.image = downloadedImage
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    
}
