//
//  PhotoDetailCollectionViewCell.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/26.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    func bind(photo: Photo) {
            
        guard let url = URL(string: photo.urls.small) else { return }
        
        photoImageView.kf.setImage(with: ImageResource(downloadURL: url, cacheKey: url.absoluteString))
    }
}
