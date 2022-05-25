//
//  LocationSearchTable.swift
//  MobileBook
//
//  Created by Yezhou Chen on 2022/4/14.
//



import Foundation
import UIKit
import MapKit
import FirebaseFirestore


class LocationSearchTable : UITableViewController {
    let db = Firestore.firestore()
    
    // search result
    var matchingItems:[MKMapItem] = []
    
    var mapView: MKMapView? = nil
    
    //write protocols
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var locationManager = CLLocationManager()
    
    
    
    var service: bookQuery?
    var allBooks = [books]() {
        didSet {
            DispatchQueue.main.async { [self] in
                varBooks = self.allBooks
            }
        }
    }
    var varBooks = [books]()
  
    override func viewDidLoad() {
        service = bookQuery()
        service?.get(collectionID: "books") { [self] varBooks in
            self.allBooks = varBooks
        }
    }
    
     func drawPinAndOverlay() {
         var nearBooksAnnotations: [MKPointAnnotation] = []
         db.collection("books").getDocuments() { (QuerySnapshot, err) in
             if let err = err {
                 print("Error getting documents : \(err)")
             }
             else {
                 for document in QuerySnapshot!.documents {
                     let bookName = document.get("bookName") as? String ?? ""
                     let author = document.get("author") as? String ?? ""
 //                    let year = document.get("author") as? Int ?? 0
                     let location = document.get("dropOffLoc") as? Array ?? [0.0,0.0]
                     let coord = CLLocationCoordinate2D(latitude: location[0] , longitude: location[1] )
                     print("Location:")
                     dump(location)
                     print("coordination:")
                     dump(coord)
                     
                     let annotation = CustomPointAnnotation()
 //                    let annotation = MKPointAnnotation()
                     annotation.category = "Book"
                     annotation.coordinate = coord
                     annotation.title = bookName
                     annotation.subtitle = author
 //                    nearBooksAnnotations.append(annotation)
                     self.mapView!.addAnnotation(annotation)
                 }
             }
         }
     }
    
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let selectedItem = matchingItems[indexPath.row].placemark
         handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        drawPinAndOverlay()
        dismiss(animated: true, completion: nil)
     }
    
    
    
};

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
                let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchBarText
            request.region = mapView.region
            let search = MKLocalSearch(request: request)
        search.start { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingItems = response.mapItems
                //debug
            print("matchingitem的长度" ,self.matchingItems.count)
                self.tableView.reloadData()
            }
    }
    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        guard let mapView = mapView,
//                let searchBarText = searchController.searchBar.text else { return }
//        let request = MKLocalSearch.Request()
//            request.naturalLanguageQuery = searchBarText
//            request.region = mapView.region
//            let search = MKLocalSearch(request: request)
//        search.start { response, _ in
//                guard let response = response else {
//                    return
//                }
//                self.matchingItems = response.mapItems
//                self.tableView.reloadData()
//            }
//    }
};

//extension LocationSearchTable {
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return matchingItems.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell")!
//        let selectedItem = matchingItems[indexPath.row].placemark
//        cell.textLabel?.text = selectedItem.name
//        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
//        return cell
//    }
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
//         let selectedItem = matchingItems[indexPath.row].placemark
//         handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
//        dismiss(animated: true, completion: nil)
//     }
//
//}
//extension LocationSearchTable {
//   override func tableView(tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
//        let selectedItem = matchingItems[indexPath.row].placemark
//        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
//       dismiss(animated: true, completion: nil)
//    }
//}


