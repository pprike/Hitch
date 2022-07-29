//
//  DataModels.swift
//  Hitch
//
import Foundation
import MapKit

struct Order {
    var distance : Double;
    var costPerDistanceUnit : Double;
    var taxAmount: Double
    var totalPrice : Double;
    var eta: Double;
}
