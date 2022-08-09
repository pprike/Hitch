//
//  UserProfileViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-08-08.
//

import Foundation
import Foundation
import UIKit
import Firebase
import FirebaseAuth
import MobileCoreServices
import FirebaseCore
import FirebaseStorage

class UserProfileViewController : UIViewController{
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var driverTag: UIButton!
    let db = Firestore.firestore()
    var imagePath: URL!
    let storage = Storage.storage()
    let userID = Auth.auth().currentUser?.uid;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo();
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        getUserInfo();
//    }
    
    func getUserInfo(){
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.uid ?? "");
             getUserFromFirebase(uid:Auth.auth().currentUser!.uid);
        }
    }
    func getUserFromFirebase(uid: String)  {
     
        let docRef = db.collection("Users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
//                type = document.get("userType") as! String;
                self.profileImage.loadFrom(URLAddress: document.get("profilePic") as! String)
                self.profileNameLabel.text = document.get("name")as? String;
                self.emailLabel.text = document.get("email")as? String;
                let age = document.get("age") as! Int;
                self.ageLabel.text = "Age \(String(age))"
                if(document.get("userType")as? String=="Driver"){
                    self.driverTag.isHidden = false
                }
            } else {
                print("User does not exist")
             }
            
            
        }
        
    }
    @IBAction func updateProfilePic(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeData)], in: .import)
                documentPicker.delegate = self
                documentPicker.allowsMultipleSelection = true
                present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction  func logOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut();
            
            let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let entryScreen = mainStoryboard.instantiateViewController(withIdentifier: "entryNav") as! UINavigationController
            UIApplication.shared.windows.first?.rootViewController = entryScreen
            UIApplication.shared.windows.first?.makeKeyAndVisible()
 
        } catch  {
            print("Error Signing out")
        }
        
    }
}

extension UserProfileViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
//        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        imagePath = selectedFileURL;
        print("FILE URL: \(String(describing: imagePath))");
        uploadToFirebase(fileUrls: imagePath, UID: userID!)
    }
    
    func uploadToFirebase(fileUrls: URL,UID: String){
        let localFile = fileUrls;
        let storageRef = storage.reference();
        let docRef = storageRef.child("profilePic/"+UID+".jpg" )
        let _ = docRef.putFile(from: fileUrls);
        // Upload the file to the path "images/rivers.jpg"
        docRef.putFile(from: localFile, metadata: nil) { metadata, error in
            guard metadata != nil else {
            // Uh-oh, an error occurred!
              print("Error__ \(String(describing: error?.localizedDescription))")
            return
          }
            docRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print("Error__ \(String(describing: error?.localizedDescription))")
              return
            }
              print("FIREBASE FILE URL: \(downloadURL)");
                let dbref = self.db.collection("Users").document(UID)
                
                let pp = ["profilePic": downloadURL.absoluteString]
                dbref.updateData(pp);
                self.profileImage.loadFrom(URLAddress: downloadURL.absoluteString);
          }
        }
            
     }
}
extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                }
            }
        }
    }
}

