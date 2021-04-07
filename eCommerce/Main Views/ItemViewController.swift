//
//  ItemViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/3/21.
//

import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    
    // MARK: - Vars
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
   
    
    // MARK: - view Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadPictures()
        
    }
    
    // MARK: - Download Pictures
    
    private func downloadPictures(){
        if item != nil && item.imageLinks.count > 0 {
            downloadImages(imageUrls: item.imageLinks) { (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
               
            }
        }
    }
    
    // MARK: - SetupUI
    
    private func setupUI(){
        if item != nil {
            navigationItem.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionView.text = item.description
            
            navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))]
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "cart"), style: .plain, target: self, action: #selector(addToCart))
            
        }
    }
    
    // MARK: - IBActions
    
    @objc func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func addToCart(){
        
        
        // check if user is logged in or show login View
        if User.currentUser() != nil {
            downloadBasketFromFirestore(User.currentId()) { (basket) in
                if basket == nil {
                    self.crateNewBasket()
                }else {
                    basket!.itemIds.append(self.item.id)
                    self.updateBasket(basket!, withValues: [kITEMIDS : basket!.itemIds])
                }
            }
          
        }else {
            showLoginView()
        }
        
        
       
        
    }
    
    // MARK: - Add to basket
    
    private func crateNewBasket(){
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = User.currentId()
        newBasket.itemIds = [item.id]
        saveBasketToFirestore(newBasket)
        
        hud.textLabel.text = "Added to basket"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    private func updateBasket(_ basket: Basket, withValues: [String : Any]){
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            if error != nil {
                print("error updating Basket", error!.localizedDescription)
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }else {
                self.hud.textLabel.text = "Added to basket"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
    // MARK: - PresentLogin View
    
    private func showLoginView(){
        let welcomVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        welcomVC.modalPresentationStyle = .fullScreen
        present(welcomVC, animated: true, completion: nil)
    }
    
    
}

extension ItemViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count != 0 ? itemImages.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        if itemImages.count > 0 {
            cell.setImageView(itemImages[indexPath.row])
        }
        return cell
    }
    
    
}

extension ItemViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 196.0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    

    
    
    
    
    
   
}
