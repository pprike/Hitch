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
    
    static let filterWithin10Kms = " Within 10 Kms"
    static let filterWithin20Kms = " Within 20 kms"
    static let filterWithin50Kms = " Within 50 kms"
    static let filterWithin100Kms = " Within 100 Kms"
    
    
    static let documents = "Documents";
    static let grocery = "Grocery / Food"
    static let electronics = "Electronics"
    static let household = "Household"
    static let clothing = "Clothing"
    static let officeSupplies = "Office Supplies"
    static let others = "Others"
    
    
    static let colorOne = UIColor(red: 151 / 255.0, green: 138 / 255.0, blue: 255 / 255.0, alpha: 1.0);
    static let colorTwo = UIColor(red: 255 / 255.0, green: 173 / 255.0, blue: 73 / 255.0, alpha: 1.0)
    static let colorThree = UIColor(red: 255 / 255.0, green: 122 / 255.0, blue: 187 / 255.0, alpha: 1.0)
    static let colorFour = UIColor(red: 88 / 255.0, green: 138 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    static let colorFive = UIColor(red: 56 / 255.0, green: 204 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    static let colorsix = UIColor(red: 255 / 255.0, green: 99 / 255.0, blue: 100  / 255.0, alpha: 1.0)
}
