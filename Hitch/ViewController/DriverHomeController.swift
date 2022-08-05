//
//  DriverHomeController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-04.
//

import Foundation
import UIKit
import MapKit
import Firebase

class DriverHomeController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nearbyTripTbl: UITableView!
    
    var orders = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nearbyTripTbl.delegate = self;
        nearbyTripTbl.dataSource = self;
        mapView.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNearbyOrders();
    }
    
    func getNearbyOrders() {
        
        let orderCollection = Firestore.firestore().collection("Orders")
            .whereField("userId", isEqualTo: Auth.auth().currentUser?.uid as Any);

       orderCollection
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting orders: \(err)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("no orders found")
                        return
                    }
                    
                    self.orders = documents
                        .compactMap { document -> Order in
                            return try! document.data(as: Order.self)
                        }
                    //Reload table on main thread asynchronously.
                    DispatchQueue.main.async {
                        self.nearbyTripTbl.reloadData()
                    }
                }
            }
        
    }
}

extension DriverHomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //header section text
        return "Nearby Orders"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //This helps in reusing the created cells.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripViewCell", for: indexPath) as! TripViewCell;
        
        //setting labels on cell.
        cell.orderId?.text = self.orders[indexPath.row].id;
        cell.orderDate?.text = self.orders[indexPath.row].orderDate;
        cell.orderTime?.text = self.orders[indexPath.row].orderTime;
        
        cell.pickupLoc?.text = self.orders[indexPath.row].pickupLocation?.address;
        cell.dropLoc?.text = self.orders[indexPath.row].dropLocation?.address;
        
        cell.orderStatus?.text = self.orders[indexPath.row].orderStatus;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
  
        let directionRequest = MKDirections.Request()
        
        
        let srcMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: self.orders[indexPath.row].pickupLocation!.lat,
            longitude: self.orders[indexPath.row].pickupLocation!.long)))
        
        let destMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: self.orders[indexPath.row].dropLocation!.lat,
            longitude: self.orders[indexPath.row].dropLocation!.long)))

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
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("Tapped")
    }
    
    func addAnnotation(_ mapItem: MKMapItem!, _ title: String) {
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = mapItem.placemark.coordinate
        self.mapView.addAnnotation(annotation)
    }
}

extension DriverHomeController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5
        renderer.strokeColor = .systemRed
        return renderer
    }
}
