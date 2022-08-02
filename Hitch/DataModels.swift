//
//  DataModels.swift
//  Hitch
//
import Foundation
import MapKit

struct Order {
    var distance: Double
    var costPerDistanceUnit: Double
    var taxAmount: Double
    var totalPrice: Double
    var eta: Double
    var packageDetails: Package
}

struct Package {
    var itemName: String
    var category: String
    var weight: Double
    var isFragile: Bool
    var count: Int
    var additionalDetails: String
    var size: ItemSize
}

struct ItemSize {
    var length: Double
    var width: Double
    var height: Double
}
