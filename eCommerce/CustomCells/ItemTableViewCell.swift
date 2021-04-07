//
//  ItemTableViewCell.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/3/21.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var imageViewItem: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

   }
    
    func generateCell(_ item: Item ){
        labelName.text = item.name
        descriptionLabel.text = item.description
        priceLabel.text = convertToCurrency(item.price)
        priceLabel.adjustsFontSizeToFitWidth = true
        
        if item.imageLinks != nil && item.imageLinks.count > 0   {
            downloadImages(imageUrls: [item.imageLinks.first!]) { (Allimage) in
                self.imageViewItem.image = Allimage.first! as? UIImage
            }
        }
    }

}
