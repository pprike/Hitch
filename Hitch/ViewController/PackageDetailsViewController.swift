//
//  PackageDetailsViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-07-12.
//

import Foundation
import UIKit

class PackageDetailsViewController: UIViewController
{
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var itemNameTxtF: UITextField!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var weightTxtF: UITextField!
    
    @IBOutlet weak var lengthTxtF: UITextField!
    
    @IBOutlet weak var widthTxtF: UITextField!
    
    @IBOutlet weak var heightTxtF: UITextField!
    
    @IBOutlet weak var isFragileSwitch: UISwitch!
    
    @IBOutlet weak var bagOrPiecesTxtF: UITextField!
    
    @IBOutlet weak var bagOrPiecesStepper: UIStepper!
    
    @IBOutlet weak var additionalDetailsTxtView: UITextView!
    
    var orderDetails : Order!
    
    var selectedCategory: String = ""
    
    let pickerData = ["Grocery / Food", "Home Furiture", "Outdoor Living", "Home Tools", "Electronics", "Office Supplies","Pet Care","Kids & Baby", "Small Appliances", "Clothing","Parcel","Documents", "Floral & Gifts","Video Games","Automotive","Health & Beauty","Other"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "OrderViewControllerSegue") {
            
            let orderView = segue.destination as! OrderViewController
            var packageDetails = self.orderDetails.packageDetails;
    
            packageDetails.itemName = self.itemNameTxtF.text!
            
            packageDetails.category = self.selectedCategory
            
            packageDetails.weight = Double(self.weightTxtF.text!) ?? 0
            
            packageDetails.size.length = Double(self.lengthTxtF.text!) ?? 0
            packageDetails.size.width = Double(self.widthTxtF.text!) ?? 0
            packageDetails.size.height = Double(self.heightTxtF.text!) ?? 0

            packageDetails.isFragile = self.isFragileSwitch.isOn
            packageDetails.count = Int(self.bagOrPiecesTxtF.text!) ?? 0
            packageDetails.additionalDetails = self.additionalDetailsTxtView.text
            
            self.orderDetails.packageDetails = packageDetails
            orderView.orderDetails = self.orderDetails
        }
    }
}

extension PackageDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource{
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
        self.selectedCategory = pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
}
