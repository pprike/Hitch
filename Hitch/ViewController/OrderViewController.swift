//
//  OrderViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-07-13.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore

class OrderViewController: UIViewController{
    
    var orderDetails : Order!
    
    //Package details
    @IBOutlet weak var itemNameLbl: UILabel!
    
    @IBOutlet weak var categoryLbl: UILabel!
    
    @IBOutlet weak var weightLbl: UILabel!
    
    @IBOutlet weak var sizeLbl: UILabel!
    
    @IBOutlet weak var isFragileLbl: UILabel!
    
    @IBOutlet weak var quantityLbl: UILabel!
    
    @IBOutlet weak var additionalDetailsLbl: UILabel!
    
    // Payment Details
    @IBOutlet weak var totalDistance: UILabel!
    
    @IBOutlet weak var costPerKm: UILabel!
    
    @IBOutlet weak var subTotal: UILabel!
    
    @IBOutlet weak var convenienceFee: UILabel!
    
    @IBOutlet weak var tax: UILabel!
    
    @IBOutlet weak var totalCost: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let distanceInKms = orderDetails.distance!/1000
        totalDistance.text = String(format: "%.2f km", distanceInKms)
        
        costPerKm.text = "$ \(orderDetails.costPerDistanceUnit!)"
        convenienceFee.text = "$ \(orderDetails.convenienceFee!)"
        
        orderDetails.subtotal = orderDetails.convenienceFee! + (distanceInKms * orderDetails.costPerDistanceUnit!)
        subTotal.text = String(format: "$ %.2f", orderDetails.subtotal!)
        
        orderDetails.taxAmount = orderDetails.subtotal! * Constants.taxRate
        tax.text = String(format: "$ %.2f", orderDetails.taxAmount!)
        
        orderDetails.totalPrice = orderDetails.taxAmount! + orderDetails.subtotal!
        totalCost.text = String(format: "$ %.2f", orderDetails.totalPrice! )
        
        itemNameLbl.text = orderDetails.packageDetails!.itemName
        categoryLbl.text = orderDetails.packageDetails!.category
        weightLbl.text = String(format: "%.2f Kgs", orderDetails.packageDetails!.weight)
        
        sizeLbl.text = "\(orderDetails.packageDetails!.size.length) X \(orderDetails.packageDetails!.size.width) X \(orderDetails.packageDetails!.size.height) cms"

        isFragileLbl.text = "\(orderDetails.packageDetails!.isFragile)"
        quantityLbl.text = "\(orderDetails.packageDetails!.count) Nos"
        additionalDetailsLbl.text = orderDetails.packageDetails!.additionalDetails
        
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "dd-MM-y";
        orderDetails.orderDate = dateFormatter.string(from: Date())
        
        dateFormatter.dateFormat = "HH:mm a"
        orderDetails.orderTime = dateFormatter.string(from: Date())
        
        do {
            let orderCollection = Firestore.firestore().collection("Orders");
            let orderId = try orderCollection.addDocument(from: orderDetails)
        } catch let error {
            print("Error writing orderdetails to Firestore: \(error)")
        }
    }
}
