//
//  DataModels.swift
//  Hitch
//
import Foundation
import MapKit
import FirebaseFirestoreSwift

struct Order: Identifiable, Codable {
    
    @DocumentID var id: String?
    var distance: Double?
    var eta: Double?
    var costPerDistanceUnit: Double?
    var taxAmount: Double?
    var totalPrice: Double?
    var convenienceFee: Double?
    var subtotal: Double?
    var packageDetails: Package?
    var orderStatus: String?
    var orderDate: String?
    var orderTime: String?
    var userId: String?
    var pickupLocation: LocationDetails?
    var dropLocation: LocationDetails?
}

struct Package: Codable {
    
    var itemName: String
    var category: String
    var weight: Double
    var isFragile: Bool
    var count: Int
    var additionalDetails: String
    var size: ItemSize
}

struct ItemSize: Codable {
    var length: Double
    var width: Double
    var height: Double
}

struct LocationDetails: Codable {
    var lat: Double
    var long: Double
    var address: String
}
