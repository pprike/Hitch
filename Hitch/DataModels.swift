//
//  DataModels.swift
//  Hitch
//
import Foundation
import MapKit

// To prepare the result list after MKLocalsearch and pass the data across
struct HospitalDetails {
    var name : String;
    var address : String;
    var location : CLLocation;
}
