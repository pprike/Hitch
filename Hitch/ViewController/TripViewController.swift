//
//  TripViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-08-01.
//

import Foundation
import UIKit
import Firebase

class TripViewController: UIViewController
{
    @IBOutlet weak var tripListTable: UITableView!
    
    var orders = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripListTable.delegate = self;
        tripListTable.dataSource = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserOrders();
    }
    
    func getUserOrders() {
        
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
                        self.tripListTable.reloadData()
                    }
                }
            }
        
    }
}

extension TripViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //header section text
        return "Recent Orders"
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
}
