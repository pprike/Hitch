//
//  DriverHomeViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-08.
//

import Foundation
import UIKit
import Firebase
import MapKit

class DriverHomeViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tripListTable: UITableView!
    
    @IBOutlet weak var filterPullDownButtom: UIButton!
    
    var orders = [Order]()
    
    var selectedOrder: Order?
    
    var range: Double = 10000
    
    var currentLoc: CLLocation?
    
    //Location manage to get the locations.
    let locationManager = CLLocationManager();
    
    //array for annotations
    var allAnnotations = [MKAnnotation]();
    
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
        setFilterPullDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNearbyOrders();
    }
    
    func setFilterPullDown() {
        
        filterPullDownButtom.showsMenuAsPrimaryAction = true
        filterPullDownButtom.changesSelectionAsPrimaryAction = true
        
        let optionClosure = {(action: UIAction) in
            
            if (action.title == Constants.filterWithin10Kms) {
                self.range = 10000
                
            } else if (action.title == Constants.filterWithin20Kms){
                self.range = 20000
            } else if (action.title == Constants.filterWithin50Kms) {
                self.range = 50000
            } else if (action.title == Constants.filterWithin100Kms) {
                self.range = 100000
            }
            
            self.getNearbyOrders()
        }
        
        filterPullDownButtom.menu = UIMenu(children: [
            UIAction(title: Constants.filterWithin10Kms, state: .on, handler: optionClosure),
            UIAction(title: Constants.filterWithin20Kms, handler: optionClosure),
            UIAction(title: Constants.filterWithin50Kms, handler: optionClosure),
            UIAction(title: Constants.filterWithin100Kms, handler: optionClosure),
        ])
    }
    
    func getNearbyOrders() {
        
        let orderCollection = Firestore.firestore().collection("Orders")
            .whereField("orderStatus", isEqualTo: Constants.orderPlaced);
        
       orderCollection
            .addSnapshotListener { [self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting orders: \(err)")
                } else {
                    guard let documents = querySnapshot?.documents else {
                        print("no orders found")
                        return
                    }
                    
                    let orders = documents
                        .compactMap { document -> Order in
                            return try! document.data(as: Order.self)
                        }
                    
                    self.orders.removeAll()
                    self.allAnnotations.removeAll();
                    
                    for order in orders {
                        
                        let pickupLocation = CLLocation(latitude: order.pickupLocation!.lat,
                            longitude: order.pickupLocation!.long)
                        
                        let distanceInMeters = pickupLocation.distance(from: self.currentLoc!)
                        
                        if (distanceInMeters < self.range) {
                            self.orders.append(order)
                            
                            //Creating annnotation with hospital coordinates.
                            let pin = MKPointAnnotation();
                            pin.coordinate = pickupLocation.coordinate;
                            pin.title = order.pickupLocation?.address;
                            pin.subtitle = String(format: "%.2f Kms", distanceInMeters/1000)
                            self.allAnnotations.append(pin)
                        }
                    }
                    
                    //add all the annotations in the list to show on map.
                    self.mapView.showAnnotations(self.allAnnotations, animated: true);
                    
                    //Reload table on main thread asynchronously.
                    DispatchQueue.main.async {
                        self.tripListTable.reloadData()
                    }
                }
            }
    }
    
    @IBAction func backBtnCliked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "NearbyOrderDetailsViewControllerSegue") {
            
            let driver = Driver(location: LocationDetails(lat: self.currentLoc!.coordinate.latitude,
                                                          long: self.currentLoc!.coordinate.longitude,
                                                          address: ""),
                                driverId: Auth.auth().currentUser!.uid)
            let orderDetailsView = segue.destination as! OrderDetailsViewController
            selectedOrder!.driverDetails = driver
            orderDetailsView.order = selectedOrder!
        }
    }
}

extension DriverHomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Orders"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //This helps in reusing the created cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripViewCell", for: indexPath) as! TripViewCell;
        
        cell.orderItemName?.text = self.orders[indexPath.row].packageDetails?.itemName
        let orderSubID = self.orders[indexPath.row].id?.prefix(8 );
        cell.orderId?.text = String(orderSubID!);
        cell.categoryImageView.image = UIImage(systemName: "cloud")
        cell.orderDate?.text = self.orders[indexPath.row].orderDate;
        cell.orderTime?.text = self.orders[indexPath.row].orderTime;
        
        cell.pickupLoc?.text = self.orders[indexPath.row].pickupLocation?.address;
        cell.dropLoc?.text = self.orders[indexPath.row].dropLocation?.address;
        let tripKm = self.orders[indexPath.row].distance! / 1000;
        cell.tripDistance.text = String(format: "%.2f Km", tripKm);
        let driversEarnings = Double(self.orders[indexPath.row].totalPrice!) - Double(self.orders[indexPath.row].convenienceFee!);
        cell.driversEarning?.text = String(format: "$ %.2f", driversEarnings);
        cell.orderStatusTag?.setTitle(self.orders[indexPath.row].orderStatus, for: .normal)
        cell.orderStatusTag?.titleLabel?.font =  UIFont(name: "system", size: 12)
        cell.orderStatusTag?.layoutIfNeeded();
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
        performSegue(withIdentifier: "NearbyOrderDetailsViewControllerSegue", sender: indexPath)
    }
    
    func updateDriverLocation(newLocation: CLLocation){
        let driversOrderCollection = Firestore.firestore().collection("Orders")
            .whereField("driverDetails.driverId", isEqualTo: Auth.auth().currentUser?.uid as Any);
        
        driversOrderCollection .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    document.reference.updateData(["driverDetails" :
                                                        [
                                                            "driverId":document.get("driverDetails.driverId"),
                                                            "location":
                                                                ["lat":newLocation.coordinate.latitude,"long":newLocation.coordinate.longitude,"address":"",]
                                                        ]
                                                  ])
                }
            }
        
        }
    }
}

extension DriverHomeViewController: CLLocationManagerDelegate {
    
    // This delegate is used to update the source location location is updated.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //  get first location and pass it futher.
        if let location = locations.first {
            
            currentLoc = location
            self.getNearbyOrders()
            self.updateDriverLocation(newLocation: location)
            zoom(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get loation: \(error)")
    }
    
    // zoom and set the region on map.
    func zoom(_ location: CLLocation) {
        
        // Fetching coordinates of the location
        let coodinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // Defines the span required by the map region.
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        //setting region to be shown on Map.
        let region = MKCoordinateRegion(center: coodinate, span: span);
        mapView.setRegion(region, animated: true)
    }
}
