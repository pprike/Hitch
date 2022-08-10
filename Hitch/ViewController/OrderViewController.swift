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
import PassKit

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
    
    var successflag: Bool = false;
    
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
    }
    
    @IBAction func backBtnCliked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private var paymentRequest : PKPaymentRequest = {
          let request = PKPaymentRequest()
          request.merchantIdentifier = "merchant.com.app.Hitchapp"
          request.supportedNetworks = [ .masterCard, .visa]
          request.supportedCountries = ["IN", "US","CA"]
          request.merchantCapabilities = .capability3DS
          request.countryCode = "CA"
          request.currencyCode = "CAD"
          return request
      }()
    
    @IBAction func orderClicked(_ sender: Any) {
        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: "Trip Payment", amount:  NSDecimalNumber(string:String(format: "%.2f",orderDetails.totalPrice!)))]
        let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                if controller != nil {
                    controller!.delegate = self
                    present(controller!, animated: true, completion: nil)
                }
    }
}
 
extension OrderViewController : PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
        controller.dismiss(animated: true, completion: nil);
        
        let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "successView")
        
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [ .medium()]
        }
        
        if successflag {
            do {
                orderDetails.orderStatus = Constants.orderPlaced

                let orderCollection = Firestore.firestore().collection("Orders");
                _ = try orderCollection.addDocument(from: orderDetails)
                present(viewController, animated: true)
            } catch let error {
                print("Error writing order details to Firestore: \(error)")
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        successflag = true;
        do {
            let orderCollection = Firestore.firestore().collection("Orders");
            _ = try orderCollection.addDocument(from: orderDetails)
        } catch let error {
            print("Error writing orderdetails to Firestore: \(error)")
        }
    }         
}
