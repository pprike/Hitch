//
//  OrderViewController.swift
//  Hitch
//
//  Created by Yash Shah on 2022-07-13.
//

import Foundation
import UIKit

class OrderViewController: UIViewController{
    
    var orderDetails : Order!
    
    @IBOutlet weak var totalDistance: UILabel!
    
    @IBOutlet weak var costPerKm: UILabel!
    
    @IBOutlet weak var subTotal: UILabel!
    
    @IBOutlet weak var tax: UILabel!
    
    @IBOutlet weak var totalCost: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let distanceInKms = orderDetails.distance/1000
        totalDistance.text = String(format: "%.2f kms", distanceInKms)
        costPerKm.text = "$ 0.40"
        
        let subTotalValue = distanceInKms * 0.40
        subTotal.text = String(format: "$ %.2f", subTotalValue)
        
        let taxValue = subTotalValue * 0.13
        tax.text = String(format: "$ %.2f", taxValue)
        
        totalCost.text = String(format: "$ %.2f", taxValue + subTotalValue)
    }
}
