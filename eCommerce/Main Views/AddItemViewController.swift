//
//  AddItemViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/2/21.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddItemViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Vars
    
    var category: Category!
    var gallery: GalleryController!
    let hud = JGProgressHUD(style: .dark)
    
    var activityIndicator: NVActivityIndicatorView?
    
    var itemImages: [UIImage?] = []
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 0.821133554, green: 0.2564511299, blue: 0.3796297014, alpha: 1), padding: .zero)
    }
    
    // MARK: - IBActions
    
    @IBAction func doneBarBtn(_ sender: UIBarButtonItem) {
        dissmisKeyboard()
        if checkFieldsAreComplited(){
            
            saveToFirebase()
            
            
        }else {
            
            hud.textLabel.text = "All Fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0, animated: true)
            print("Error all fields are required!")
            //TODO: SHOW ERROR TO THE USER
        }
        
    }
    
    
    @IBAction func cameraBtnPressed(_ sender: UIButton) {
        itemImages = []
        showImageGallery()
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dissmisKeyboard()
        
    }
    
    // MARK: - Helper Functions
    
    private func dissmisKeyboard(){
        self.view.endEditing(false)
    }
    
    private func checkFieldsAreComplited() -> Bool {
        return (titleTextField.text != "" && priceTextField.text != "" && descriptionTextView.text != "")
    }
    
    private func dissmisView (){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Save Item
    private func saveToFirebase(){
        showLoadingIndicator()
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text!
        item.categoryId = category.id
        item.description = descriptionTextView.text!
        item.price = Double(priceTextField.text!) ?? 0.0
        
        if itemImages.count > 0 {
            upLoadImages(images: itemImages, itemId: item.id) { (imageLinksArray) in
                item.imageLinks = imageLinksArray
                //saving Items
                saveItemsToFirestore(item)
                saveItemToAlgolia(item)
                
                self.hideLoadingIndicator()
                self.dissmisView()
                
            }
            
        }else {
            saveItemsToFirestore(item)
            saveItemToAlgolia(item)
            
            hideLoadingIndicator()
            dissmisView()
            
        }
    }
    // MARK: - Activiry Indicator
    private func showLoadingIndicator(){
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
        
    }
    private func hideLoadingIndicator(){
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
            
        }
    }
    
    // MARK: - Show Gallery
    
    private func showImageGallery(){
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 6
        
        self.present(self.gallery, animated: true, completion: nil)
    }
    
}

extension AddItemViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages = resolvedImages
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
