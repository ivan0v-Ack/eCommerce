//
//  User.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/4/21.
//

import Foundation
import FirebaseAuth


class User {
    var objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName:String
    var purchasedItemIds:[String]
    
    var fullAdress: String?
    var onBoard: Bool
    
    init(_objectId: String,_email: String,_firstName: String, _lastName: String){
        self.objectId = _objectId
        self.email = _email
        self.firstName = _firstName
        self.lastName = _lastName
        self.fullName = _firstName + _lastName
        self.purchasedItemIds = []
        self.onBoard = false
    }
    
    init(_dictionary: NSDictionary) {
        self.objectId = _dictionary[kOBJECTID] as? String ?? ""
        self.email = _dictionary[kEMAIL] as? String ?? ""
        self.firstName = _dictionary[kFIRSTNAME] as? String ?? ""
        self.lastName = _dictionary[kLASTNAME] as? String ?? ""
        self.fullName = self.firstName + " " + self.lastName
        self.purchasedItemIds = _dictionary[kPURCHASEDITEMIDS] as? [String] ?? []
        self.fullAdress = _dictionary[kFULLADRESS] as? String ?? ""
        self.onBoard = _dictionary[kONBOARD] as? Bool ?? false
        
    }
    
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> User? {
        
        if Auth.auth().currentUser != nil {
            
            if let dictinary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return User(_dictionary: dictinary as! NSDictionary)
                
            }
        }
        return nil
    }
    
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?,_ isEmailVerified: Bool) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil {
                if authDataResult!.user.isEmailVerified {
                    downloadUserFromFirestore(authDataResult!.user.uid, emial: email)
                    completion(error, true)
                }else {
                    print("email is not verified!")
                    completion(error, false)
                }
            }else {
                print("Error with login User", error!.localizedDescription)
                completion(error, false)
            }
        }
    }
    
    class func registerUser(email: String, password: String, completion: @escaping (_ error: Error?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
            completion(error)
            if error == nil {
                authData?.user.sendEmailVerification(completion: { (error) in
                    if let error = error {
                        print("auth email verification error: " , error.localizedDescription)
                    }
                })
            }
            
        }
}
    // MARK: - Resend link methods
    
    class func resendPassword(_ email: String, completion: @escaping(_ error: Error?)-> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    class func resendVerificationEmail(_ emailAdress: String, completion: @escaping (_ error: Error?) -> Void){
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                print("resend email error :", error?.localizedDescription)
                completion(error)
            })
        })
    }
    
    class func logOutCurrentUser(completion: @escaping(_ error: Error?)-> Void){
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            completion(nil)
        }catch let error as NSError {
            completion(error)
            
        }
    }
}

// MARK: - Helper functions
 
func userDictionary(_ user: User) -> NSDictionary {
    return NSDictionary(objects: [user.objectId, user.email, user.firstName, user.lastName, user.fullName, user.purchasedItemIds, user.fullAdress ?? "", user.onBoard], forKeys: [kOBJECTID as NSCopying, kEMAIL as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kPURCHASEDITEMIDS as NSCopying,kFULLADRESS as NSCopying, kONBOARD as NSCopying])
}

// MARK: - download user

func downloadUserFromFirestore(_ userId: String, emial: String){
    
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        if snapshot.exists {
            print("download current user from Firestore")
            saveUserLocally(snapshot.data()! as NSDictionary)
        }else {
            //there is no user, save new in firestore
            
            let user = User(_objectId: userId, _email: emial, _firstName: "", _lastName: "")
            saveUserLocally(userDictionary(user))
            saveUserToFirestore(user)
        }
    }
}





// MARK: - Saving Function

func saveUserToFirestore(_ user: User){
    
    FirebaseReference(.User).document(user.objectId).setData(userDictionary(user) as! [String : Any]) { (error) in
        if error != nil {
            print ("error saving user :", error!.localizedDescription)
        }
    }
}

func saveUserLocally(_ userDictionary: NSDictionary){
    
    UserDefaults.standard.setValue(userDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
    
}

// MARK: - updateUser

func updateCurrentUserInFirestore(_ withValues: [String: Any], completion: @escaping (_ error: Error?)-> Void){
    
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        
        FirebaseReference(.User).document(User.currentId()).updateData(withValues) { (error) in
            completion(error)
            
            if error == nil {
                saveUserLocally(userObject)
            }
        }
        
        
    }
    
}


