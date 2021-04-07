//
//  CategoryCollectionViewCell.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/1/21.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(_ category: Category){
        nameLabel.text = category.name
        imageView.image = category.image
    }
}
