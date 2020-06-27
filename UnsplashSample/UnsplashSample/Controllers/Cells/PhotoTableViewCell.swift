//
//  PhotoTableViewCell.swift
//  UnsplashSample
//
//  Created by Gilwan Ryu on 2020/06/26.
//  Copyright © 2020 GilwanRyu. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoNamelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(photo: Photo) {
            
        photoImageView.backgroundColor = UIColor(hexString: photo.color)
        photoNamelabel.text = photo.user.name
        
        guard let url = URL(string: photo.urls.small) else { return }
        
        photoImageView.kf.setImage(with: ImageResource(downloadURL: url, cacheKey: url.absoluteString))
    }
}
