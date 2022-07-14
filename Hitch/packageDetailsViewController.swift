//
//  packageDetailsViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-07-12.
//

import Foundation
//
//  ViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-06-19.
//

import UIKit

class packageDetailsViewController: UIViewController
{
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var categoryPicker: UIPickerView!
    let pickerData = ["Grocery / Food", "Home Furiture", "Outdoor Living", "Home Tools", "Electronics", "Office Supplies","Pet Care","Kids & Baby", "Small Appliances", "Clothing","Parcel","Documents", "Floral & Gifts","Video Games","Automotive","Health & Beauty","Other"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
}

extension packageDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
