//
//  Items.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/2/21.
//

import Foundation
import UIKit


class Item {
    
    var id: String = String()
    var categoryId: String = String()
    var name: String = String()
    var description: String = String()
    var price: Double = Double()
    var imageLinks: [String] = [String]()
    
    init(){
    }
    
    init(_dictionary: NSDictionary){
        self.id = _dictionary[kOBJECTID] as! String
        self.categoryId = _dictionary[kCategoryId] as! String
        self.name = _dictionary[kNAME] as! String
        self.description = _dictionary[kDesreption] as! String
        self.price = _dictionary[kPrice] as! Double
        self.imageLinks = _dictionary[kImageLinks] as! [String]
        
    }
    
}
// MARK: - save items to Firestore
func saveItemsToFirestore(_ item: Item){
    
    
    FirebaseReference(.Items).document(item.id).setData(itemDictionaryFrom(item) as! [String:Any])
}


// MARK: - Helper functions

func itemDictionaryFrom(_ item: Item) -> NSDictionary {
    return NSDictionary(objects: [item.id, item.categoryId, item.name, item.description, item.price, item.imageLinks], forKeys: [kOBJECTID as NSCopying, kCategoryId as NSCopying, kNAME as NSCopying, kDesreption as NSCopying, kPrice as NSCopying, kImageLinks as NSCopying ])
}

// MARK: - download Items from Firebase

func downloadItemsFromFirebase(_ withCategoryId: String, completion: @escaping (_ itemArray: [Item]) -> Void){
    
    var itemArr = [Item]()
    
    FirebaseReference(.Items).whereField(kCategoryId, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        if error != nil {
            completion(itemArr)
            return
        }
        guard let snapshot = snapshot else {
            completion(itemArr)
            return
        }
        
        if !snapshot.isEmpty {
            for item in snapshot.documents {
                itemArr.append(Item(_dictionary: item.data() as NSDictionary))
            }
        }
        completion(itemArr)
    }
}

func downloadItemWithId(_ itemIds: [String], completion: @escaping (_ Items: [Item]) -> Void){
    
    var items: [Item] = []
    var counter = 0
    
    if itemIds.count > 0 {
        for itemId in itemIds {
            FirebaseReference(.Items).document(itemId).getDocument { (snapshot, error) in
                if error != nil {
                    print("Coudn't download Items", error!.localizedDescription)
                    completion(items)
                }
                guard let snapshot = snapshot else {
                    completion(items)
                    return
                }
                if snapshot.exists {
                    items.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    counter += 1
                }else {
                    completion(items)
                }
                
                if counter == itemIds.count {
                    completion(items)
                }
            }
        }
    }else {
        completion(items)
    }
    
}

