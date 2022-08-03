//
//  LoginViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-07-26.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
       
        self.hideKeyboardWhenTappedAround()
        if Auth.auth().currentUser?.uid != nil{
        
        do{
            try Auth.auth().signOut()
        } catch{
            print(error.localizedDescription)
         }
        }
    }
    
    

    @IBAction func login(_ sender: Any) {
        loginBtn.titleLabel?.text = ""
        loader.isHidden = false;
        
        if userEmail.text?.isEmpty == true || userPassword.text?.isEmpty == true{
        return
        }
        checkLogin();
    }
    
    func checkLogin(){
        Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { authData, error in
            if let err = error{
                print("Error: LC001  \(err.localizedDescription)");
                let alert = UIAlertController(title: "Login Failed",
                                              message: err.localizedDescription,
                                              preferredStyle: .alert)

                // 2. Creeate Actions
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: { _ in
                     print("OK tap")
                }))

                // 3. Snow
                self.present(alert, animated: true, completion: nil)
                return;
            }
            self.checkUserInfo();
        }
    }

    func checkUserInfo(){
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.uid ?? "");
             getUserFromFirebase(uid:Auth.auth().currentUser!.uid);
//            let defaults = UserDefaults.standard
//            defaults.set(true, forKey: "isLoggedIn");
        }
    }
    
    func getUserFromFirebase(uid: String)  {
        var screen = "mainBottomNav";
        var type: String = "";
        let docRef = db.collection("Users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                type = document.get("userType") as! String;
            } else {
                print("Document does not exist")
            }
            if type == "Driver"{
                screen = "driverMainTab"
            }
            let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: screen)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true);
        }
        
    }
    
    
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if identifier == "login" {
//            if Auth.auth().currentUser?.uid != nil {
//                print("User ID: \(Auth.auth().currentUser?.uid ?? "")");
//
//            return true;
//        }
//        }
//        return false;
//    }
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
