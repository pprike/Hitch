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
    @IBOutlet weak var uploadDocsBtn: UIButton!
    var filePath: URL!
    
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()

    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
       
    }

    @IBAction func signUpClicked(_ sender: Any) {
        if userEmail.text?.isEmpty == true || password.text?.isEmpty == true || userAge.text?.isEmpty == true || confirmPassword.text?.isEmpty == true || userName.text?.isEmpty == true {
            print("Email and Password Required");
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
            let type = userTypeControl.selectedSegmentIndex==0 ? "Patron" : "Driver";
            let User =  UserModel(id:user?.uid,name:userName.text,email:userEmail.text,age:Int(userAge.text!),password:self.password.text,userType:type);
            userCollection.document(user!.uid).setData(User.dictionary);
            if((filePath) != nil){
                uploadToFirebase(fileUrls: filePath, UID: user!.uid);
            }
//          userCollection.addDocument(data: User.dictionary);
            var screen = "mainBottomNav";
            if type=="Driver"{
                screen = "driverMainTab"
            }
            let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: screen)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true);
        }
        
    }

    @IBAction func userTypeChanged(_ sender: Any) {
        if(userTypeControl.selectedSegmentIndex==1){
            uploadDocsBtn.isHidden = false;
        }else{
            uploadDocsBtn.isHidden = true;
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
//        uploadToFirebase(fileUrls:selectedFileURL);
    }
    
    func uploadToFirebase(fileUrls: URL,UID: String){
        let localFile = fileUrls;
        let storageRef = storage.reference();
        let docRef = storageRef.child("DriverDocs/"+fileUrls.lastPathComponent)
        let uploadTask_ = docRef.putFile(from: localFile);
            docRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print("Error__ \(error?.localizedDescription)")
              return
            }
              print("FIREBASE FILE URL: \(downloadURL)");
          }
        }
            
//    }
}


