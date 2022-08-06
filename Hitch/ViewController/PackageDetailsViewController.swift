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
    
    @IBOutlet weak var disclaimerSwitch: UISwitch!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var orderDetails : Order!
    
    var selectedCategory: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround();
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        categoryPicker.selectedRow(inComponent: 0)
        
        nextBtn.isEnabled = disclaimerSwitch.isOn;
        
    }
    
    @IBAction func disclamerValueChanged(_ sender: UISwitch) {
        
        nextBtn.isEnabled = sender.isOn
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "OrderViewControllerSegue") {
            
            let orderView = segue.destination as! OrderViewController
            
            let packageDetails = Package(itemName: self.itemNameTxtF.text!,
                                         category: self.selectedCategory,
                                         weight: Double(self.weightTxtF.text!) ?? 0,
                                         isFragile: self.isFragileSwitch.isOn,
                                         count: Int(self.bagOrPiecesTxtF.text!) ?? 0,
                                         additionalDetails: self.additionalDetailsTxtView.text,
                                         size: ItemSize(length: Double(self.lengthTxtF.text!) ?? 0,
                                                        width: Double(self.widthTxtF.text!) ?? 0,
                                                        height: Double(self.heightTxtF.text!) ?? 0))
            
            self.orderDetails.packageDetails = packageDetails
            self.orderDetails.costPerDistanceUnit = Constants.costPerKm
            self.orderDetails.convenienceFee = Constants.convenienceFee
            
            orderView.orderDetails = self.orderDetails
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PackageDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.categories.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCategory = Constants.categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
}
