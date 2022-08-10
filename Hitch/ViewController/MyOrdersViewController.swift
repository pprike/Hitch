//
//  TripViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-01.
//

import Foundation
import UIKit
import Firebase
import MapKit

class MyOrdersViewController: UIViewController
{
    @IBOutlet weak var tripListTable: UITableView!
    
    var orders = [Order]()
    
    var selectedOrder: Order?
    
    var range: Double = 5000
    
    var currentLoc: CLLocation?
    
    @IBOutlet weak var earningsLbl: UILabel!
    
    //Location manage to get the locations.
    let locationManager = CLLocationManager();
    
    var totalEarnings : Double! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripListTable.delegate = self;
        tripListTable.dataSource = self;
        
        //Setting up location manager.
        locationManager.delegate = self;
        locationManager.requestAlwaysAuthorization();
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        //Initializing default location when app opens.
        let defaultLocation : [CLLocation] = [CLLocation(latitude: 43.466667, longitude: -80.516670)];
        locationManager(locationManager, didUpdateLocations: defaultLocation);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserOrders();
    }
    
    func getUserOrders() {
        
        var orderCollection: Query?
        
        if (Constants.userType == Constants.userDriver) {
            orderCollection = Firestore.firestore().collection("Orders")
                .whereField("driverDetails.driverId", isEqualTo: Auth.auth().currentUser?.uid as Any);
        } else {
            orderCollection = Firestore.firestore().collection("Orders")
                .whereField("userId", isEqualTo: Auth.auth().currentUser?.uid as Any);
        }
        
        orderCollection!
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
                    
                    if (Constants.userType == Constants.userDriver) {
                        for order in  self.orders {
                            self.totalEarnings += (order.totalPrice! - order.convenienceFee!)
                        }
                        
                        self.earningsLbl.isHidden = false
                        self.earningsLbl.text = String(format: "$ %.2f", self.totalEarnings!)
                    } else {
                        self.earningsLbl.isHidden = true
                    }
                   
                    //Reload table on main thread asynchronously.
                    DispatchQueue.main.async {
                        self.tripListTable.reloadData()
                    }
                }
            }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "OrderDetailsViewControllerSegue") {
            
            let orderDetailsView = segue.destination as! OrderDetailsViewController
            orderDetailsView.order = selectedOrder!
        }
    }
}

extension MyOrdersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Orders"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //This helps in reusing the created cells
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
        self.selectedOrder = orders[indexPath.row]
        performSegue(withIdentifier: "OrderDetailsViewControllerSegue", sender: indexPath)
    }
}

extension MyOrdersViewController: CLLocationManagerDelegate {
    
    // This delegate is used to update the source location location is updated.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //  get first location and pass it futher.
        if let location = locations.first {
            
            currentLoc = location
            if (Constants.userType == Constants.userDriver) {
                self.getUserOrders()
            }
        }
    }
}
