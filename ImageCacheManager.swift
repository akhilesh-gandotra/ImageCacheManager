//
//  ImageCacheManager.swift
//  ImageCacheManager
//
//  Created by Akhilesh on 05/03/18.
//  Copyright © 2018 Akhilesh. All rights reserved.
//

import Foundation
import UIKit

class ImageCacheManager {
    private let maxCacheSize = 100
    static let shared: ImageCacheManager = ImageCacheManager()
    private var imageCache = [String: UIImage]()
    
    func cacheImage(url: String, image: UIImage) {
        if imageCache.count > maxCacheSize {
            self.imageCache.remove(at: imageCache.startIndex)
        }
        self.imageCache[url] = image
    }
    
    
      func cachedImageForURL(_ url: String) -> UIImage? {
        return imageCache[url]
    }
       func clearCache() {
        imageCache.removeAll()
    }
    
    func downloadImageFromURL(urlString: String, completion: ((_ success: Bool, _ image: UIImage?) -> Void)?) {
        // do we have this cached?
        if let cachedImage = cachedImageForURL(urlString) {
            DispatchQueue.main.async(execute: {completion?(true, cachedImage) })
        } else if let url = URL(string: urlString) { // download from URL asynchronously
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: url, completionHandler: { (retrievedURL, response, error) -> Void in
                var found = false
                if error != nil { print("Error downloading image \(url.absoluteString): \(error!.localizedDescription)") }
                else if retrievedURL != nil {
                    if let data = try? Data(contentsOf: retrievedURL!) {
                        if let image = UIImage(data: data) {
                            found = true
                            self.cacheImage(url: urlString, image: image)
                            DispatchQueue.main.async(execute: { completion?(true, image) })
                        }
                    }
                }
                if !found { DispatchQueue.main.async(execute: { completion?(false, nil) })}
            })
            downloadTask.resume()
        } else { completion?(false, nil) }
    }
}
