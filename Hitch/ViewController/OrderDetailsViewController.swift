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
    
    @IBOutlet weak var userDetailsLbl: UILabel!
    
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
    
    @IBOutlet weak var acceptBtn: UIButton!
    
    @IBOutlet weak var trackBtn: UIButton!
    
    @IBOutlet weak var tripCostLbl: UILabel!
    
    var tripValue: Double?
    
    var order: Order?
    
    var nextOrderState: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (Constants.userType == Constants.userPatron) {
            acceptBtn.isHidden =  true
            trackBtn.isHidden = false
            userDetailsLbl.text = "Driver Details"
            tripCostLbl.text = "Total Cost"
            tripValue = order!.totalPrice!
        } else {
            acceptBtn.isHidden =  false
            trackBtn.isHidden = true
            userDetailsLbl.text = "Consignee Details"
            tripCostLbl.text = "Earnings"
            tripValue = order!.totalPrice! - order!.convenienceFee!
        }
        
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
        
        tripPriceLbl.text = String(format: "$ %.2f", tripValue!)
        
        if ( order!.orderStatus == Constants.orderPlaced) {
            nextOrderState = Constants.orderAssigned
            acceptBtn.setTitle("Accept Order", for: UIControl.State.normal)
        } else if ( order!.orderStatus == Constants.orderAssigned) {
            nextOrderState = Constants.orderPickedUp
            acceptBtn.setTitle("Mark as Picked Up", for: UIControl.State.normal)
        } else if ( order!.orderStatus == Constants.orderPickedUp) {
            nextOrderState = Constants.orderComplete
            acceptBtn.setTitle("Mark as Delivered", for: UIControl.State.normal)
        } else if ( order!.orderStatus == Constants.orderComplete) {
            nextOrderState = Constants.orderComplete
            acceptBtn.isHidden = true
            trackBtn.isHidden = true
        }
    }
    
    func  populateUserDetails() {
    
        var userId : String
        
        if (Constants.userType == Constants.userPatron) {
            userId = order!.driverDetails?.driverId! ?? ""
        } else {
            userId = order!.userId!
        }
        
        if (userId != "") {
            let docRef = Firestore.firestore().collection("Users")
                .document(userId)
            
            docRef.getDocument { (document, error) in
                
                if let document = document, document.exists {
                    self.userNametxtF.text = (document.get("name") as! String);
                    self.userEmailTxtF.text = (document.get("email") as! String);
                    
                    if (Constants.userType == Constants.userPatron) {
                        self.trackBtn.isEnabled = true
                    }
                }
            }
        } else {
            self.userNametxtF.text = "Not Assigned"
            self.userEmailTxtF.text = "Not Assigned"
            
            if (Constants.userType == Constants.userPatron) {
                self.trackBtn.isEnabled = false
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
    
    @IBAction func acceptBtnClicked(_ sender: Any) {
        do {
            self.order!.orderStatus = nextOrderState
            let orderCollection = Firestore.firestore().collection("Orders");
            _ = try orderCollection.document(order!.id!).setData(from: order!)
            
            let alert = UIAlertController(title: "Order Details", message: "Order Status Updated",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action)-> Void in
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 1
        } catch let error {
            print("Error updating order details to Firestore: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "TrackOrderViewControllerSegue") {
            
            let trackOrderView = segue.destination as! TrackOrderViewController
            trackOrderView.order = self.order!
        }
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
