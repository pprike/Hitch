//
//  Constants.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-02.
//

import UIKit

struct Constants {
        
    static let categories = ["Grocery / Food", "Home Furiture", "Outdoor Living", "Home Tools", "Electronics", "Office Supplies","Pet Care","Kids & Baby", "Small Appliances", "Clothing","Parcel","Documents", "Floral & Gifts","Video Games","Automotive","Health & Beauty","Other"];
    
    static let taxRate = 0.13;
    
    static let costPerKm = 0.40;
    
    static  let convenienceFee = 2.0;
    
    static var userType = ""
    
    static let userDriver = "Driver"
    static let userPatron = "Patron"
    
    static let orderPlaced = "PLACED"
    static let orderAssigned = "ASSIGNED"
    static let orderPickedUp = "PICKED"
    static let orderComplete = "COMPLETE"
    static let orderCancelled = "CANCELLED"
    
    static let filterWithin10Kms = "Within 10 Kms"
    static let filterWithin20Kms = "Within 20 kms"
    static let filterWithin50Kms = "Within 50 kms"
    static let filterWithin100Kms = "Within 100 Kms"
}
