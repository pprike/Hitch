//
//  TrackOrderViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-09.
//

import Foundation
import UIKit
import MapKit
import Firebase

class TrackOrderViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var driverNameLbl: UILabel!
    
    @IBOutlet weak var driverContactLbl: UILabel!
    
    @IBOutlet weak var etaLbl: UILabel!
    
    @IBOutlet weak var userProfileImgView: UIImageView!
    
    var order : Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        drawRoute()
    }
    
    func drawRoute() {
                
        let orderCollection = Firestore.firestore().collection("Orders")
            .whereField("id", isEqualTo: self.order.id!);
        
        orderCollection
            .addSnapshotListener { [self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting orders: \(err)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("no orders found")
                        return
                    }
                    print("something changes");
                    let orders = documents
                        .compactMap { document -> Order in
                            return try! document.data(as: Order.self)
                        }
                    
                    for order in orders {
                        if (self.order.id == order.id) {
                            self.order = order
                        }
                    }
                }
            }
                
        
        let docRef = Firestore.firestore().collection("Users")
            .document((order.driverDetails?.driverId)!)
        
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                self.driverNameLbl.text = (document.get("name") as! String);
                self.driverContactLbl.text = (document.get("phone") as! String);
                
                let image = document.get("profilePic") as! String;
                if image.isEmpty != true{
                    self.userProfileImgView.loadFrom(URLAddress: image)
                }
            }
        }
        
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
  
        let directionRequest = MKDirections.Request()
        
        let srcMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: self.order!.pickupLocation!.lat,
            longitude: self.order!.pickupLocation!.long)))
        
        let destMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: self.order!.dropLocation!.lat,
            longitude: self.order!.dropLocation!.long)))
        
        let driverMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: self.order!.driverDetails!.location!.lat,
            longitude: self.order!.driverDetails!.location!.long)))

        self.addAnnotation(srcMapItem, "Pickup")
        self.addAnnotation(destMapItem, "Drop")
        
        if ( order!.orderStatus == Constants.orderPlaced) {
            directionRequest.source = srcMapItem
            directionRequest.destination = destMapItem
        } else if ( order!.orderStatus == Constants.orderAssigned) {
            self.addAnnotation(driverMapItem, "Driver")
            directionRequest.source = driverMapItem
            directionRequest.destination = srcMapItem
        } else if ( order!.orderStatus == Constants.orderPickedUp) {
            self.addAnnotation(driverMapItem, "Driver")
            directionRequest.source = driverMapItem
            directionRequest.destination = destMapItem
        }
        
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
            
            let (h, m, _) = self.secondsToHoursMinutesSeconds(seconds: Int(route.expectedTravelTime))
            self.etaLbl.text = ("\(h) Hours, \(m) Minutes")
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }

    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func addAnnotation(_ mapItem: MKMapItem!, _ title: String) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = mapItem.placemark.coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TrackOrderViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5
        renderer.strokeColor = .systemRed
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation.title == "Driver") {
            return nil
        }

        let reuseId = "driverAnn"

        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
            anView!.isHighlighted = true
        }
        else {
            anView!.annotation = annotation
        }

        let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
        anView!.image = UIImage(systemName: "car", withConfiguration: symbolConfig)

        return anView
    }
}
