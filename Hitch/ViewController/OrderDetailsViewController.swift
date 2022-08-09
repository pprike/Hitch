//
//  OrderDetailsViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-04.
//

import Foundation
import UIKit
import MapKit
import Firebase

class OrderDetailsViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var profilePicImgView: UIImageView!
    
    @IBOutlet weak var userNametxtF: UILabel!
    
    @IBOutlet weak var userEmailTxtF: UILabel!
    
    @IBOutlet weak var itemLbl: UILabel!
    
    @IBOutlet weak var categoryLbl: UILabel!
    
    @IBOutlet weak var weightLbl: UILabel!
    
    @IBOutlet weak var sizeLbl: UILabel!
    
    @IBOutlet weak var isFragile: UILabel!
    
    @IBOutlet weak var quantityLbl: UILabel!
    
    @IBOutlet weak var noteLbl: UILabel!
    
    @IBOutlet weak var tripPriceLbl: UILabel!
    
    @IBOutlet weak var acceptBtnLbl: UIButton!
    
    var order : Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self;
        
        if (Constants.userType == Constants.userPatron) {
            acceptBtnLbl.isHidden =  true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        drawRoute()
        populateUserDetails()
        populateOderDetails()
    }
    
    func  populateOderDetails() {
       
        itemLbl.text = order!.packageDetails!.itemName
        categoryLbl.text = order!.packageDetails!.category
        weightLbl.text = String(format: "%.2f Kgs", order!.packageDetails!.weight)
        sizeLbl.text = "\(order!.packageDetails!.size.length) X \(order!.packageDetails!.size.width) X \(order!.packageDetails!.size.height) cms"
        
        isFragile.text = "\(order!.packageDetails!.isFragile)"
       
        quantityLbl.text = "\(order!.packageDetails!.count) Nos"
       
        noteLbl.text = order!.packageDetails!.additionalDetails
        
        tripPriceLbl.text = String(format: "$ %.2f", (order!.totalPrice! - order!.convenienceFee!))
    }
    
    func  populateUserDetails() {
        
        let docRef = Firestore.firestore().collection("Users")
            .document(order!.userId!)
        
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                self.userNametxtF.text = (document.get("name") as! String);
                self.userEmailTxtF.text = (document.get("email") as! String);
             }
        }
    }
    
    func drawRoute() {
        
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
  
        let directionRequest = MKDirections.Request()
        
        let srcMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: self.order!.pickupLocation!.lat,
            longitude: self.order!.pickupLocation!.long)))
        
        let destMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: self.order!.dropLocation!.lat,
            longitude: self.order!.dropLocation!.long)))

        self.addAnnotation(srcMapItem, "Pickup")
        self.addAnnotation(destMapItem, "Drop")
        
        directionRequest.source = srcMapItem
        directionRequest.destination = destMapItem
        
        directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        
        direction.calculate { (response, error) in
            guard let response =  response else {
                if let error = error {
                    print("Error in getting directions: \(error.localizedDescription)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                           edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30),
                                           animated: true)
        }
    }
    
    func addAnnotation(_ mapItem: MKMapItem!, _ title: String) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = mapItem.placemark.coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func backBtnCliked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension OrderDetailsViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5
        renderer.strokeColor = .systemRed
        return renderer
    }
}
