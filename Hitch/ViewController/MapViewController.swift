//
//  MapViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-07-16.
//


import UIKit
import MapKit
import FirebaseAuth

class MapViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pickupLocTxtF: UITextField!
    
    @IBOutlet weak var destLocTxtF: UITextField!
    
    private var selectedTxtField : UITextField!
    
    private var srcMapItem : MKMapItem!
    
    private var destMapItem : MKMapItem!
    
    private var annotations = [MKAnnotation?](repeating: nil, count: 2)
        
    private var orderDetails : Order!
    
    //Location manage to get the locations.
    let locationManager = CLLocationManager();
    
    
    override func viewDidLoad() {
        
        //Setting up location manager.
        locationManager.delegate = self;
        locationManager.requestAlwaysAuthorization();
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true;
        mapView.isZoomEnabled = true
        
        pickupLocTxtF.delegate = self;
        destLocTxtF.delegate = self;
        
        self.mapView.delegate = self
        
        //Initializing default location when app opens.
        let defaultLocation : [CLLocation] = [CLLocation(latitude: 43.466667, longitude: -80.516670)];
        locationManager(locationManager, didUpdateLocations: defaultLocation);
        
        orderDetails = Order()
        orderDetails.userId = Auth.auth().currentUser!.uid
    }

    
    @IBAction func selectionLocationTextFTouched(_ sender: UITextField) {
        self.selectedTxtField = sender;
        performSegue(withIdentifier: "SearchViewControllerSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "SearchViewControllerSegue") {
            
            self.segueForSearchViewControllerSegue(segue, sender)
            
        } else if (segue.identifier == "PackageDetailsViewControllerSegue") {
            
            let orderView = segue.destination as! PackageDetailsViewController
            orderView.orderDetails = self.orderDetails
            
        }
    }
    
    func segueForSearchViewControllerSegue(_ segue: UIStoryboardSegue, _ sender: Any?) {
        
        let destView = segue.destination as! SearchViewController
        destView.mapView = self.mapView
        
        destView.callBack = { (mapItem: MKMapItem) in
            
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            let location = LocationDetails(lat: mapItem.placemark.coordinate.latitude,
                                           long: mapItem.placemark.coordinate.longitude,
                                           address: mapItem.placemark.title!)
            
            if (self.selectedTxtField == self.pickupLocTxtF) {
                self.srcMapItem = mapItem
                self.orderDetails.pickupLocation = location
            } else {
                self.destMapItem = mapItem
                self.orderDetails.dropLocation = location
            }
            
            self.selectedTxtField.text = mapItem.placemark.title
        
            self.addAnnotation(self.srcMapItem)
            self.addAnnotation(self.destMapItem)
            
            
            if ( self.srcMapItem != nil && self.destMapItem != nil ) {
                let directionRequest = MKDirections.Request()
                directionRequest.source = self.srcMapItem
                directionRequest.destination = self.destMapItem
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
                                        
                    self.orderDetails.distance = route.distance
                    self.orderDetails.eta = route.expectedTravelTime
                }
            }
        }
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5
        renderer.strokeColor = .systemRed
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    // This delegate is used to update the source location location is updated.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //  get first location and pass it futher.
        if let location = locations.first {
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
    
    func addAnnotation(_ mapItem: MKMapItem!) {
        
        if (mapItem != nil) {
            self.mapView.addAnnotation(mapItem.placemark)
        }
    }
}
