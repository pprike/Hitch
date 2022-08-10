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
        
    @IBOutlet weak var categoryPopUpBtn: UIButton!
    
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
        nextBtn.isEnabled = disclaimerSwitch.isOn;
        setCategoryPopUp()
    }
    
    func setCategoryPopUp() {
        
        categoryPopUpBtn.showsMenuAsPrimaryAction = true
        categoryPopUpBtn.changesSelectionAsPrimaryAction = true
        
        let optionClosure = {(action: UIAction) in
            self.selectedCategory = action.title
        }
        
        categoryPopUpBtn.menu = UIMenu(children: [
            
            UIAction(title: Constants.documents, state: .on, handler: optionClosure),
            UIAction(title: Constants.grocery, handler: optionClosure),
            UIAction(title: Constants.electronics, handler: optionClosure),
            UIAction(title: Constants.household, handler: optionClosure),
            UIAction(title: Constants.clothing, handler: optionClosure),
            UIAction(title: Constants.officeSupplies, handler: optionClosure),
            UIAction(title: Constants.others, handler: optionClosure),
        ])
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
    @IBAction func stepperClicked(_ sender: UIStepper) {
        bagOrPiecesTxtF.text = Int(sender.value).description
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
