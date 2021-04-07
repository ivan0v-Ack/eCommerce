//
//  CategoryCollectionViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/1/21.
//

import UIKit



class CategoryCollectionViewController: UICollectionViewController {
    // MARK: - Vars
    var categoryArray: [Category] = []
    private let sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    private let itemsPerRow: CGFloat = 3
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCatecories()
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }

    // MARK: - UICollectionView DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categoryArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        let catecory = categoryArray[indexPath.row]
        cell.generateCell(catecory)
        return cell
    }
    
    // MARK: - UIColectionView Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "categoryToItemsSeg", sender: categoryArray[indexPath.row])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryToItemsSeg" {
            let vc = segue.destination as! ItemsTableViewController
            vc.category = sender as! Category
        }
    }
    
    // MARK: - Download categories
    private func loadCatecories(){
        downloadCategoriesFromFirebase { (AllCategories) in
            self.categoryArray = AllCategories
            self.collectionView.reloadData()
        }
    }
    }

extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInset.left * (itemsPerRow + 1)
        let availableWidth = view.frame.size.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInset.left
       
    }
}
