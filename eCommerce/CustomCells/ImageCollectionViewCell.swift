//
//  ImageCollectionViewCell.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/3/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImageView(_ image : UIImage){
        imageView.image = image
        
        
    }
}
