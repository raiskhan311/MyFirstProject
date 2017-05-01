//
//  UIImageView+Cache.swift
//  Airstrike
//
//  Created by Bret Smith on 12/28/16.
//  Copyright © 2016 TitleIO. All rights reserved.
//

import UIKit

extension UIImageView {
    
    
    public func cache_imageForURL(_ urlString: String?) {
        
        //Placeholder image set here
        self.image = #imageLiteral(resourceName: "noImage")
        guard let url = urlString else { return }
        downloadImage(url)
    }
    
    fileprivate func downloadImage(_ urlString: String) {
        
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if (error == nil) {
                // Success
                guard let imageData = data else { return }
                let imageRetrieved = UIImage(data: imageData)
                
                DispatchQueue.main.async {
                    self.image = imageRetrieved
                }
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
}
