//
//  SignUpViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-07-26.
//

import Foundation
import Foundation
import UIKit
import Firebase
import FirebaseAuth
import MobileCoreServices
import FirebaseCore
import FirebaseStorage


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userType: UISegmentedControl!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var userAge: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userTypeControl: UISegmentedControl!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var uploadDocsBtn: UIButton!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var boxHeight: NSLayoutConstraint!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var forgetLabelBottomMargin: NSLayoutConstraint!
    var filePath: URL!
    
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()

    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
       
    }

    @IBAction func signUpClicked(_ sender: Any) {
        if userEmail.text?.isEmpty == true || password.text?.isEmpty == true || userAge.text?.isEmpty == true || confirmPassword.text?.isEmpty == true || userName.text?.isEmpty == true || phoneNo.text?.isEmpty == true {
            print("Data Required");
            displayMessage(title: "Data Required", msg: "Please fill all data")
            return
        }
        if((confirmPassword?.text != password?.text) && password.text!.count > 8 ){
            displayMessage(title: "Invalid Password", msg: "Password and Confirm Password should be same and atleast 8 characters ")
        }
        signUp();
    }
   
    func signUp() {
        Auth.auth().createUser(withEmail: userEmail.text!, password: password.text!) { [self] (authResult, error) in
            guard case let user = authResult?.user, error == nil else {
                print("Error \(String(describing: error?.localizedDescription) )");
                displayMessage(title: "SignUp Failed", msg: error!.localizedDescription);
                return
            }
            print("User: \(String(describing: user?.uid))")
            let userCollection = Firestore.firestore().collection("Users");
            let type = userTypeControl.selectedSegmentIndex==0 ? Constants.userPatron : Constants.userDriver;
            let User =  UserModel(id:user?.uid,name:userName.text,email:userEmail.text,age:Int(userAge.text!),password:self.password.text,userType:type,phone:phoneNo.text);
            userCollection.document(user!.uid).setData(User.dictionary);
            if((filePath) != nil){
                uploadToFirebase(fileUrls: filePath, UID: user!.uid);
            }
//          userCollection.addDocument(data: User.dictionary);
//            var screen = "mainBottomNav";
//            if type == Constants.userDriver{
//                screen = "driverMainTab"
//            }
            let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainTabController") as! UITabBarController
            
            if type == Constants.userDriver {
                Constants.userType = Constants.userDriver
                viewController.viewControllers?.remove(at: 0)
            } else {
                Constants.userType = Constants.userPatron
            }
                            
            UIApplication.shared.windows.first?.rootViewController = viewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        
    }

    @IBAction func userTypeChanged(_ sender: Any) {
        if(userTypeControl.selectedSegmentIndex==1){
            boxHeight.constant = 550;
            boxView.layoutIfNeeded();
            forgetLabelBottomMargin.constant = 10;
            uploadDocsBtn.isHidden = false;
            fileInfoLabel.isHidden = false;
        }else{
            boxHeight.constant = 500;
            forgetLabelBottomMargin.constant = 50;
            boxView.layoutIfNeeded();
            
            uploadDocsBtn.isHidden = true;
            fileInfoLabel.isHidden = true;
        }
    }
    @IBAction func uploadDocClicked(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText),String(kUTTypeContent),String(kUTTypeData)], in: .import)
                documentPicker.delegate = self
                documentPicker.allowsMultipleSelection = true
                present(documentPicker, animated: true, completion: nil)
    
    }
    
    func displayMessage (title: String,msg: String){

        let alert = UIAlertController(title: title,message: msg,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
             print("OK tap")}))
        present(alert, animated: true, completion: nil)
    }
}

extension SignUpViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        filePath = sandboxFileURL;
        print("FILE URL: \(String(describing: filePath))");
//        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
//            print("Already exists! Do nothing");
//            do{
//                try FileManager.default.removeItem(at: sandboxFileURL);
//                print("Already exists! and Deleted");
//            }catch{
//                //error
//            }
//        }
//        else {
//
//            do {
//                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
//
//                print("Copied file!")
//            }
//            catch {
//                print("Error: \(error)")
//            }
//        }
//        uploadToFirebase(fileUrls:filePath,UID: "0wB2EGNC8QUYeTMgRYfR9kwXT7Y2");
    }
    
    func uploadToFirebase(fileUrls: URL,UID: String){
        let localFile = fileUrls;
        let storageRef = storage.reference();
        let docRef = storageRef.child("driverDocs/"+fileUrls.lastPathComponent)
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
          }
        }
            
     }
}


