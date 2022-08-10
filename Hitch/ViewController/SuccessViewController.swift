//
//  SuccessViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-08-09.
//

import Foundation
import UIKit

class SuccessViewController: UIViewController{
    
    @IBOutlet weak var successImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad();
        let successGif = UIImage.gifImageWithName("success")
        successImage.image = successGif;
    }
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true);
        navigationController?.popToRootViewController(animated: true)
    }
}
