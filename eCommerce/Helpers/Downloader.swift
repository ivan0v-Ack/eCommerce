//
//  Downloader.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/2/21.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()

// MARK: - Upload Images

func upLoadImages(images: [UIImage?], itemId: String, completion: @escaping (_ imageLinks: [String])-> Void){
    
    if Reachability.isConnectedToNetwork(){
        var uploadImagesCount = 0
        var imageLinkArray: [String] = []
        var nameSuffix = 0
        
        for image in images {
            
            let fileName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.5)
            
            saveImageInStorage(imageData: imageData!, fileName: fileName) { (imageLink) in
                if imageLink != nil {
                    imageLinkArray.append(imageLink!)
                    
                    uploadImagesCount += 1
                    
                    if uploadImagesCount == images.count {
                        completion(imageLinkArray)
                    }
                }
            }
            nameSuffix += 1
        }
        
    }else {
        print("No Internet Connection")
    }
}

func saveImageInStorage(imageData: Data, fileName: String, completion: @escaping (_ imageLink: String?) -> Void) {
    
    var task: StorageUploadTask!
    let storageRef = storage.reference(forURL: kFILEREFERANCE).child(fileName)
    
    task = storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
        task.removeAllObservers()
        
        if error != nil {
            print("Error uploading image", error!.localizedDescription)
            completion(nil)
            return
        }
        storageRef.downloadURL { (url, error) in
            guard let downloadUrl = url else {
                completion (nil)
                return
            }
            completion(downloadUrl.absoluteString)
        }
    })
    
}


func downloadImages(imageUrls: [String], completion: @escaping (_ images:[UIImage?])-> Void){
    
    var imageArray = [UIImage]()
    var downloadCounter = 0
    
    for link in imageUrls {
        
        let url = NSURL(string: link)
        
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            
            downloadCounter += 1
            
            let data = NSData(contentsOf: url! as URL)
            
            if data != nil {
                imageArray.append(UIImage(data: data! as Data)!)
                
                if downloadCounter == imageUrls.count {
                    DispatchQueue.main.async {
                        completion(imageArray)
                    }
                    
                }
            }else {
                print("Couldn't download images")
                completion(imageArray)
            }
        }
    }
}
