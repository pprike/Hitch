//
//  SearchViewController.swift
//  Hitch
//
//  Created by Parikshit Murria on 2022-07-15.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchResultsTbl: UITableView!
    
    public var mapView: MKMapView!
        
    public var callBack: ((_ mapItem: MKMapItem )-> Void)?
    
    // Create a search completer object
    var searchCompleter = MKLocalSearchCompleter()

    // These are the results that are returned from the searchCompleter & what we are displaying
    // on the searchResultsTbl
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        searchBar?.delegate = self
        searchResultsTbl?.delegate = self
        searchResultsTbl?.dataSource = self
    }
}

// Setting up extensions for the table view
extension SearchViewController: UITableViewDataSource {
// This method declares the number of sections that we want in our table.
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}

// This method declares how many rows are the in the table
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
}

// This method declares the cells that are table is going to show at a particular index
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   // Get the specific searchResult at the particular index
   let searchResult = searchResults[indexPath.row]

   //Create  a new UITableViewCell object
   let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

   //Set the content of the cell to our searchResult data
   cell.textLabel?.text = searchResult.title
   cell.detailTextLabel?.text = searchResult.subtitle

    return cell
  }
}

extension SearchViewController: UITableViewDelegate {
    // This method declares the behavior of what is to happen when the row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        searchRequest.region = mapView.region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            
            guard let mapItem = response?.mapItems[0] else {
                return
            }
            
            self.callBack?(mapItem)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

extension SearchViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Setting our searchResults variable to the results that the searchCompleter returned
        searchResults = completer.results

        // Reload the tableview with our new searchResults
        searchResultsTbl.reloadData()
    }

    // This method is called when there was an error with the searchCompleter
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Failed to search with error: \(error)")
    }
}
