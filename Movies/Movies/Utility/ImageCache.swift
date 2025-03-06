//
//  ImageCache.swift
//  Movies
//
//  Created by Baljeet Singh Raghav on 04/03/25.
//

import Foundation
import UIKit
let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImage(from url: String) {
        guard let imageUrl = URL(string: "https://image.tmdb.org/t/p/w500\(url)") else { return }
        
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                    imageCache.setObject(image, forKey: url as NSString)
                }
            }
        }.resume()
    }
}
