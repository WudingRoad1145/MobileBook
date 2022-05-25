//
//  homePageViewController.swift
//  MobileBook
//
//  Created by 丁予哲 on 3/26/22.
//

import UIKit
import CoreLocation
import MapKit
import SwiftUI
import FirebaseFirestore



protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class homePageViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate{
    
    var name = ""
    var author = ""

//    class homePageViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, HandleMapSearch {


    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet var profileButton: UIBarButtonItem!
    /*
    var service: bookQuery?
    var allBooks = [books]() {
        didSet {
            DispatchQueue.main.async { [self] in
                varBooks = self.allBooks
            }
        }
    }
    var varBooks = [books]()
     */
    //static let booktable = ListViewController()
    //var allBooksData = booktable.allBooks
    let db = Firestore.firestore()
    
    var locationManager = CLLocationManager()
    // for the search part
    var resultSearchController:UISearchController? = nil
    

    var selectedPin:MKPlacemark? = nil
    

    var targetCoord: CLLocationCoordinate2D?
    var titleLabel: UILabel?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        myMap.delegate = self
        
        
        locationManager.requestWhenInUseAuthorization()
        
        // gesture
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(homePageViewController.handleLongTapGesture(gestureRecognizer:)))
        longTapGesture.delegate = self
        myMap.addGestureRecognizer(longTapGesture)
        
        
        
        profileButton.image = UIImage(systemName: "person.circle")
        profileButton.tintColor = .black
        
        let currLongitude = locationManager.location?.coordinate.longitude ?? -78.939767
        let currLatitude = locationManager.location?.coordinate.latitude ?? 36.001678
        let currCoord = CLLocationCoordinate2D(latitude: currLatitude, longitude: currLongitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: currCoord, span: span)
        myMap.setRegion(region, animated: true)
        
        
        //for the search part and the locationsearchtable
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.handleMapSearchDelegate = self
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        //configures the search bar need to connect with the search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = myMap
        /*
        service = bookQuery()
        service?.get(collectionID: "books") { [self] varBooks in
            self.allBooks = varBooks
        }*/
        loadData()
        drawPinAndOverlay()

    }
    
    @objc func handleLongTapGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UILongPressGestureRecognizer.State.ended {
            let touchLocation = gestureRecognizer.location(in: myMap)
            let locationCoordinate = myMap.convert(touchLocation, toCoordinateFrom: myMap)
            
//            print("Tap location : (\(locationCoordinate.longitude), \(locationCoordinate.latitude))")
            
            let myPin = CustomPointAnnotation()
            myPin.category = "Drop"
            myPin.coordinate = locationCoordinate
            myPin.title = "Drop book here!"
            
            myMap.addAnnotation(myPin)
        }
        
        if gestureRecognizer.state != UILongPressGestureRecognizer.State.began {
            return
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
                    self.myMap.addAnnotation(annotation)
                }
            }
        }
//        print(nearBooksAnnotations.count)
//        myMap.addAnnotations(nearBooksAnnotations)
    }
    
    //MARK: Mapkit Delegate methods
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = mapView.selectedAnnotations.first else {
            return
        }
        
        targetCoord = annotation.coordinate
//        print("Before segueway, tapped annotation: \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
        titleLabel?.text = annotation.title as? String
        
        let newAnno = annotation as! CustomPointAnnotation
        
        if newAnno.category == "Book"{
            self.performSegue(withIdentifier: "ReserveBook", sender: self)
                    }
        else if newAnno.category == "Drop" {
                        self.performSegue(withIdentifier: "EnterBookInfo", sender: self)
                    }
    }
    
    
    
    
    
    
    
    
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }

        let reuseId = "test"

        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "test")
        
        let test = annotation as! CustomPointAnnotation
        if test.category == "Drop" {
            annotationView.glyphImage = UIImage(systemName: "a.book.closed.fill")
            annotationView.markerTintColor = UIColor.green
        } else if test.category == "Book" {
            annotationView.glyphImage = UIImage(systemName: "a.book.closed.fill")
            annotationView.markerTintColor = UIColor.blue
        } else {
            annotationView.glyphImage = UIImage(systemName: "mappin")
        }
        annotationView.canShowCallout = true
        annotationView.calloutOffset = CGPoint(x: -5, y: 5)
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotationTitle = view.annotation?.title {
            print("User tapped on annotation with title: \(annotationTitle!)")
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.blue.withAlphaComponent(0.8)
            renderer.lineWidth = 5
            return renderer
        }

        return MKOverlayRenderer()
    }

    
    // MARK: - CoreLocation Delegate method
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("App is authorized")
            locationManager.startUpdatingLocation()
        }
        
        if status == .notDetermined || status == .denied {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
        //print("Location \(locations.first)")
        print("Latitude = \(locations.first!.coordinate.latitude)")
        print("Longitude = \(locations.first!.coordinate.longitude)")
        
        locationManager.stopUpdatingLocation()
        
    }

    func jumpToDropViewController(segue: UIStoryboardSegue) {
        if let VC = segue.destination as? DropViewController, let myCoord = targetCoord {
            VC.targetCoord = myCoord
        }
    }
    
    func jumpToReserveViewController(segue: UIStoryboardSegue) {
            if let VC = segue.destination as? PickViewController, let titleLabel = titleLabel {
                VC.titleLabel = titleLabel
            }
        }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        case "EnterBookInfo":
            jumpToDropViewController(segue: segue)
        case "ReserveBook":
            jumpToReserveViewController(segue: segue)
        default:
            print("Something went wrong")
        }
    }
    
    func loadData() {
        db.collection("books").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents : \(err)")
            }
            else {
                for document in QuerySnapshot!.documents {
                    let bookName = document.get("bookName") as? String ?? ""
                    let author = document.get("author") as? String ?? ""
                    let year = document.get("author") as? Int ?? 0
                    let location = document.get("dropOffLoc") as? Array ?? [0,0]
                }
            }
        }
    }
    


};


extension homePageViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        myMap.removeAnnotations(myMap.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        myMap.addAnnotation(annotation)
        
        
        let currLongitude = locationManager.location?.coordinate.longitude ?? -78.939767
        let currLatitude = locationManager.location?.coordinate.latitude ?? 36.001678
        let currCoord = CLLocationCoordinate2D(latitude: currLatitude, longitude: currLongitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: currCoord, span: span)
        myMap.setRegion(region, animated: true)
    }
}




