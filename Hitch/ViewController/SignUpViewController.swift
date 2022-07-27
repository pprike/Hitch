//
//  SignUpViewController.swift
//  Hitch
//
//  Created by Aayushi Luhar on 2022-07-26.
//

import Foundation
import Foundation
import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userEmail: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
       
    }

    @IBAction func signUpClicked(_ sender: Any) {
        if userEmail.text?.isEmpty == true || password.text?.isEmpty == true {
            print("Email and Password Required");
            return
        }
        signUp();
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: userEmail.text!, password: password.text!) { (authResult, error) in
            guard case let user = authResult?.user, error == nil else {
                print("Error \(error?.localizedDescription)");
                return
            }
//            print("User: \(String(describing: user))")
//            let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
//            let vc = mainStoryboard.instantiateViewController(withIdentifier: "mainBottomNav")
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true);
        }
    }
}
