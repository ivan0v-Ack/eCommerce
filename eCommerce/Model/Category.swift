//
//  Category.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/1/21.
//

import Foundation
import UIKit



class Category {
    
    var id: String
    var name: String
    var image: UIImage?
    var imageName: String?
    
    init(_name: String, _imageName: String){
        self.id = ""
        self.name = _name
        self.imageName = _imageName
        self.image = UIImage(named: _imageName)
        
    }
    
    init(_dictionary: NSDictionary) {
        self.id = _dictionary[kOBJECTID] as! String
        self.name = _dictionary[kNAME] as! String
        self.image = UIImage(named: _dictionary[kIMAGENAME] as? String ?? "")
    }
    
}

// MARK: - Download Category from Firebase

func downloadCategoriesFromFirebase(completion: @escaping (_ caregoryArr: [Category]) -> Void){
    var categoryArray: [Category] = []
    
    FirebaseReference(.Category).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(categoryArray)
            return
        }
        if !snapshot.isEmpty {
            for categoryDict in snapshot.documents {
                categoryArray.append(Category(_dictionary: categoryDict.data() as NSDictionary))
            }
            completion(categoryArray)
            
        }
        
    }
}

// MARK: - Save category function

func saveCategoryToFirebase(_ category: Category){
    
    let id = UUID().uuidString
    category.id = id
    
    FirebaseReference(.Category).document(id).setData(categoryDictionaryFrom(category) as! [String: Any])
}

// MARK: - Helpers

func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
    return NSDictionary(objects: [category.id, category.name, category.imageName], forKeys: [kOBJECTID as NSCopying, kNAME as NSCopying, kIMAGENAME as NSCopying])
}

// MARK: - use only one time

//func createCategotySet() {
//
//    let womenClothing = Category(_name: "Women's Clothing & Accessories", _imageName: "womenCloth")
//    let electronics = Category(_name: "Footwear", _imageName: "footWear")
//    let menClothing = Category(_name: "Men's Clothing & Accessories", _imageName: "menCloths")
//    let health = Category(_name: "Health & Beauty", _imageName: "health")
//    let baby = Category(_name: "Baby Stuff", _imageName: "baby")
//    let home = Category(_name: "Home & Kitchen", _imageName: "home")
//    let car = Category(_name: "Automobiles & Motorcyles", _imageName: "car")
//    let luggage = Category(_name: "Luggage & bags", _imageName: "luggage")
//    let jewelery = Category(_name: "Jewelery", _imageName: "jewelery")
//    let hobby = Category(_name: "Hobby,Sport, Traveling", _imageName: "hobby")
//    let pet = Category(_name: "Pet products", _imageName: "pet")
//    let industry = Category(_name: "Industry & Business", _imageName: "industry")
//    let garden = Category(_name: "Garden supplies", _imageName: "garden")
//    let camera = Category(_name: "Cameras & Optics", _imageName: "camera")
//    let secondHand = Category(_name: "Second Hand", _imageName: "secondHand")
//
//    let arrayOfCategories = [womenClothing,electronics,menClothing,health,baby,home,car,luggage,jewelery,hobby,pet,industry,garden,camera,secondHand]
//
//    for catecory in arrayOfCategories {
//        saveCategoryToFirebase(catecory)
//    }
//
//}
