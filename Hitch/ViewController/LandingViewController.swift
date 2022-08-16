//
//  LandingViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-08-16.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class LandingViewController: UIViewController{
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var goToLoginBtn: UIButton!
    @IBOutlet weak var goToSignUpBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if Auth.auth().currentUser?.uid != nil{
            getUserFromFirebase(uid: Auth.auth().currentUser!.uid)
        }else{
            goToLoginBtn.isHidden = false;
            goToSignUpBtn.isHidden = false;
        }
       
    }
    
    func getUserFromFirebase(uid: String)  {
        let docRef = db.collection("Users").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let userType = document.get("userType") as! String;
                
                let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainTabController") as! UITabBarController
                
                if userType == Constants.userDriver {
                    Constants.userType = Constants.userDriver
                    viewController.viewControllers?.remove(at: 0)
                } else {
                    Constants.userType = Constants.userPatron
                    viewController.viewControllers?.remove(at: 1)
                }
                                
                UIApplication.shared.windows.first?.rootViewController = viewController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
                
            } else {
                print("Document does not exist")
            }
        }
    }
      
}
