//
//  Cart.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/3/21.
//

import Foundation

class Basket {
    
    var id: String = String()
    var ownerId: String = String()
    var itemIds: [String] = [String]()
    
    init() {
     }
    
    init(_dictionary: NSDictionary) {
        self.id = _dictionary[kOBJECTID] as! String
        self.ownerId = _dictionary[kOWNERID] as! String
        self.itemIds = _dictionary[kITEMIDS] as! [String]
    }
    }

// MARK: - save to Firebase

func saveBasketToFirestore(_ basket: Basket) {
    
 FirebaseReference(.Basket).document(basket.id).setData(basketDictionary(basket) as! [String:Any])
}

// MARK: - Download Items

func downloadBasketFromFirestore(_ ownerId : String, completion: @escaping(_ basket: Basket?) -> Void){
    
    FirebaseReference(.Basket).whereField(kOWNERID, isEqualTo: ownerId).getDocuments { (snapshot, error) in
        if error != nil {
            print("Cound't download data from basket" , error!.localizedDescription)
            completion(nil)
        }
        guard let snapshot = snapshot else {
            completion(nil)
            return
        }
        if !snapshot.isEmpty && snapshot.documents.count > 0 {
            let basket = Basket(_dictionary: snapshot.documents.first!.data() as NSDictionary)
            completion(basket)
        }else {
            completion(nil)
        }
    }
    
}
// MARK: - helper functions
func basketDictionary(_ basket: Basket) -> NSDictionary {
    return NSDictionary(objects: [basket.id, basket.ownerId, basket.itemIds], forKeys: [kOBJECTID as NSCopying, kOWNERID as NSCopying, kITEMIDS as NSCopying])
}

// MARK: - Update basket

func updateBasketInFirestore(_ basket: Basket, withValues: [String: Any], completion: @escaping (_ error: Error?) -> Void){
    
    FirebaseReference(.Basket).document(basket.id).updateData(withValues) { (error) in
        completion(error)
    }
    
    
}
