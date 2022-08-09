//
//  TrackOrderViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-09.
//

import Foundation
import UIKit
import MapKit

class TrackOrderViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    var order : Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
