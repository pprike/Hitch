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
        cell.orderItemName?.text = self.orders[indexPath.row].packageDetails?.itemName
        let orderSubID = self.orders[indexPath.row].id?.prefix(8 );
        cell.orderId?.text = String(orderSubID!);
        cell.orderDate?.text = self.orders[indexPath.row].orderDate;
        cell.orderTime?.text = self.orders[indexPath.row].orderTime;
        
        cell.pickupLoc?.text = self.orders[indexPath.row].pickupLocation?.address;
        cell.dropLoc?.text = self.orders[indexPath.row].dropLocation?.address;
        
        cell.orderStatusTag?.setTitle(self.orders[indexPath.row].orderStatus, for: .normal)
        cell.orderStatusTag.titleLabel?.font =  UIFont(name: "system", size: 12)
        cell.orderStatusTag.layoutIfNeeded();
        print(self.orders[indexPath.row].packageDetails?.category as Any)
        switch self.orders[indexPath.row].packageDetails?.category{
        case Constants.documents:
            cell.categoryImageView.image = UIImage(systemName: "folder");
            cell.imageBgView.backgroundColor = Constants.colorOne;
            break
        case Constants.grocery:
            cell.categoryImageView.image = UIImage(systemName: "cup.and.saucer");
            cell.imageBgView.backgroundColor = Constants.colorTwo;
            break
        case Constants.electronics:
            cell.categoryImageView.image = UIImage(systemName: "ipod");
            cell.imageBgView.backgroundColor = Constants.colorThree ;
            break
        case Constants.clothing:
            cell.categoryImageView.image = UIImage(systemName: "tshirt");
            cell.imageBgView.backgroundColor = Constants.colorFour;
            break
        case Constants.officeSupplies:
            cell.categoryImageView.image = UIImage(systemName: "pencil.tip.crop.circle");
            cell.imageBgView.backgroundColor = Constants.colorFive;
            break
        case Constants.household:
            cell.categoryImageView.image = UIImage(systemName: "house");
            cell.imageBgView.backgroundColor = Constants.colorsix;
            break
        default:
            cell.categoryImageView.image = UIImage(systemName: "line.3.horizontal.decrease.circle");
            cell.imageBgView.backgroundColor = Constants.colorOne 
            break
        }
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
