//
//  addPlaceViewController.swift
//  toVisitPlaces_anmol_c0777245
//
//  Created by Anmol singh on 2020-06-14.
//  Copyright © 2020 Swift Project. All rights reserved.
//

import UIKit
import MapKit

class addPlaceViewController: UIViewController,  MKMapViewDelegate, UITabBarDelegate, UITabBarControllerDelegate {

    
    var favoritePlaces: [FavoritePlace]?
    var favoriteAddress: String?
        @IBOutlet weak var mapObject: MKMapView!
        let locationManager: CLLocationManager = {
            let manager = CLLocationManager()
            manager.requestWhenInUseAuthorization()
            return manager
        }()
        var tappedLocation: CLLocationCoordinate2D?
        @IBOutlet weak var findMyWayBtn: UIButton!
        @IBOutlet weak var routeTabBar: UITabBar!
        @IBOutlet weak var zoomStepper: UIStepper!
        
    var favoriteLocation: CLLocation?
        
        var stepperComparingValue = 0.0
        
        let request = MKDirections.Request()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
                mapObject.delegate = self
            // map intialzing
                setUpMapView()
            //find my way button attribute
                findMyWayBtn.layer.cornerRadius = 30
                findMyWayBtn.layer.borderWidth = 1
                findMyWayBtn.layer.borderColor = UIColor.white.cgColor
                findMyWayBtn.widthAnchor.constraint(equalToConstant: 125.0).isActive = true
                findMyWayBtn.heightAnchor.constraint(equalToConstant: 25.0).isActive = true

            //route tab bar requested route and visibility
                routeTabBar.delegate = self
            // handle double tap
                let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
                tap.numberOfTapsRequired = 2
                view.addGestureRecognizer(tap)
            
            //MARK:- Notification for checking when user went out of app
//                NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: UIApplication.willResignActiveNotification, object: nil)
                
                loadData()
        }
    
    func getDataFilePath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let filePath = documentPath.appending("/Favorite-Place-Data.txt")
        return filePath
    }
    
    func loadData(){
        favoritePlaces = [FavoritePlace]()

        let filePath = getDataFilePath()
        if FileManager.default.fileExists(atPath: filePath) {

            do{
                //creating string of file path
                let fileContent = try String(contentsOfFile: filePath)
                // seperating books from each other
                let contentArray = fileContent.components(separatedBy: "\n")
                for content in contentArray {
                    //seperating each book's content
                    let favoritePlaceContent = content.components(separatedBy: ",")
                    if favoritePlaceContent.count == 6 {
                        let favoritePlace = FavoritePlace(lat: Double(favoritePlaceContent[0])!, long: Double(favoritePlaceContent[1])!, speed: Double(favoritePlaceContent[2])!, course: Double(favoritePlaceContent[3])!, altitude: Double(favoritePlaceContent[4])!, address: favoritePlaceContent[5])
                        favoritePlaces?.append(favoritePlace)
                    }
                }

            }catch {
                print(error)
            }
        }
    }
    
      // calling variable of another viewcontroller
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let favoritePlacesListTableVC = segue.destination as? FavoritePlacesTableViewController {
                favoritePlacesListTableVC.favoritePlaces = self.favoritePlaces
            }
        }
        
        @objc func saveData() {
            let filePath = getDataFilePath()
            
            var saveString = ""
            
            for favoritePlace in self.favoritePlaces! {
                saveString = "\(saveString)\(favoritePlace.lat),\(favoritePlace.long),\(favoritePlace.speed),\(favoritePlace.course),\(favoritePlace.altitude),\(favoritePlace.address)\n"
            }
            
            do{
                try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
            } catch {
                print(error)
            }
            
            
        }
    

        
        //MARK: double tap function
        @objc func doubleTapped(gestureRecognizer: UITapGestureRecognizer)
        {
            // remove all annotations(markers)
            let allAnnotations = self.mapObject.annotations
            self.mapObject.removeAnnotations(allAnnotations)
            //remove overlays
            mapObject.removeOverlays(mapObject.overlays)
            //location finder with double tap
            let location = gestureRecognizer.location(in: mapObject)
            
            self.tappedLocation = mapObject.convert(location, toCoordinateFrom: mapObject)
            
            self.favoriteLocation = CLLocation(latitude: self.tappedLocation?.latitude ?? 0.00, longitude: self.tappedLocation?.longitude ?? 0.00)
            //annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.tappedLocation!
            annotation.title = "Location Tapped"
            annotation.subtitle = "Your Desired Location"
            // custom annotation
            mapObject.addAnnotation(annotation)
            routeTabBar.isHidden = true
            findMyWayBtn.isHidden = false
        }
        
        //MARK:- Stepper value change
        @IBAction func zoomStepperValueChange(_ sender: UIStepper) {

            let stepperValue = zoomStepper.value
            if(stepperValue > self.stepperComparingValue){

                var region: MKCoordinateRegion = mapObject.region
                region.span.latitudeDelta /= 2.0
                region.span.longitudeDelta /= 2.0
                mapObject.setRegion(region, animated: true)
                self.stepperComparingValue = stepperValue
            }else if(stepperValue < self.stepperComparingValue){

                var region: MKCoordinateRegion = mapObject.region
                  region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
                  region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
                  mapObject.setRegion(region, animated: true)
                self.stepperComparingValue = stepperValue
            }
        }
        
    //MARK: setting up map
        func setUpMapView() {
                mapObject.showsUserLocation = true
                mapObject.showsCompass = true
                mapObject.showsScale = true
                mapObject.isZoomEnabled = false
                mapObject.isScrollEnabled = true
            // call for current location
               currentLocation()
            }
            
        //MARK: current location
        func currentLocation() {
               locationManager.delegate = self
               locationManager.desiredAccuracy = kCLLocationAccuracyBest
               if #available(iOS 11.0, *) {
                  locationManager.showsBackgroundLocationIndicator = true
               } else {
                  // code for earlier version
               }
               locationManager.startUpdatingLocation()
            }
        
        //MARK: find my way
        @IBAction func findMyWay(_ sender: UIButton) {

                let sourceLat = mapObject.userLocation.location?.coordinate.latitude ?? 0.00
                let sourceLong = mapObject.userLocation.location?.coordinate.longitude ?? 0.00
                let destinationLat = self.tappedLocation?.latitude ?? 0.00
                let destinationLong = self.tappedLocation?.longitude ?? 0.00
                print("Source: \(sourceLat) , \(sourceLong)")
                print("Destination: \(destinationLat) , \(destinationLong)")
                    if(sourceLat == 0.0 || sourceLong == 0.0){
                        let alert = UIAlertController(title: "Location couldn't retrieve!!", message: "Simulate Location from your xcode", preferredStyle: UIAlertController.Style.alert)
                                      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                      self.present(alert, animated: true, completion: nil)
                }
                    else if(destinationLat == 0.0 || destinationLong == 0.0){
                        let alert = UIAlertController(title: "Alert", message: "Please double tap to select destination", preferredStyle: UIAlertController.Style.alert)
                           alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                           self.present(alert, animated: true, completion: nil)
                    }else{
            
            let alert = UIAlertController(title: "Choose!!", message: "Please select the route type", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Walking", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in

                self.routeTabBar.selectedItem = self.routeTabBar.items?[0]
                self.request.transportType = .walking
                self.routeFinder()
            }))
            alert.addAction(UIAlertAction(title: "Automobile", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in

                self.routeTabBar.selectedItem = self.routeTabBar.items?[1]
                    self.request.transportType = .automobile
                    self.routeFinder()
                   }))
            self.present(alert, animated: true, completion: nil)
       
            }
            }
        
        //MARK: func route variation
        func routeFinder(){
            //source and destination lat and long
            let sourceLat = mapObject.userLocation.location?.coordinate.latitude ?? 0.00
            let sourceLong = mapObject.userLocation.location?.coordinate.longitude ?? 0.00
            let destinationLat = self.tappedLocation?.latitude ?? 0.00
            let destinationLong = self.tappedLocation?.longitude ?? 0.00
            print("Source: \(sourceLat) , \(sourceLong)")
            print("Destination: \(destinationLat) , \(destinationLong)")
                routeTabBar.isHidden = false
                findMyWayBtn.isHidden = true
                // request globally declared
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong), addressDictionary: nil))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong), addressDictionary: nil))
                request.requestsAlternateRoutes = true
                   

                let directions = MKDirections(request: request)

                directions.calculate { [unowned self] response, error in
                    guard let unwrappedResponse = response else { return }

                    for route in unwrappedResponse.routes {
                        self.mapObject.addOverlay(route.polyline)
                            self.mapObject.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
        }
        
        //MARK: map view delegate
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if self.request.transportType == .automobile
            {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5.0
            renderer.alpha = 0.80
                return renderer
                
            }else if self.request.transportType == .walking {
                let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
                renderer.strokeColor = UIColor.red
                renderer.lineDashPattern = [5, 10]
                renderer.lineWidth = 5.0
                renderer.alpha = 0.80
                return renderer
            }
            
            return MKOverlayRenderer()
        }
       
        //MARK: route tab bar
        func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            if(item == routeTabBar.items?[0]){
                //remove overlays
                mapObject.removeOverlays(mapObject.overlays)
                self.request.transportType = .walking
                routeTabBar.selectedItem = routeTabBar.items?[0]
                routeFinder()
            }else if(item == routeTabBar.items?[1]){
                //remove overlays
                mapObject.removeOverlays(mapObject.overlays)
                self.request.transportType = .automobile
                routeTabBar.selectedItem = routeTabBar.items?[1]
                routeFinder()
            }
        }
    
    //MARK: View for annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           if annotation is MKUserLocation{
            return nil

        }
                    let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                    pinAnnotation.animatesDrop = true
                    pinAnnotation.canShowCallout = true
                    pinAnnotation.rightCalloutAccessoryView = UIButton(type: .contactAdd)
                    return pinAnnotation
    }

        //MARK:- callout accessory
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
                let alert = UIAlertController(title: "Favorite Place", message: "Do you want to add this to your favorite place list?", preferredStyle: .alert)
            let addAction = UIAlertAction(title: "Add", style: .cancel) { (UIAlertAction) in
//                print("Data Addition process")

                let lat = self.favoriteLocation?.coordinate.latitude
                let long = self.favoriteLocation?.coordinate.longitude
                let speed = self.favoriteLocation?.speed
                let course = self.favoriteLocation?.course
                let altitude = self.favoriteLocation?.altitude
                
                CLGeocoder().reverseGeocodeLocation(self.favoriteLocation ?? CLLocation() ) { (placemarks, error) in
                             if error != nil {
                                 print("Error found: \(error!)")
                             } else {
                                 if let placemark = placemarks?[0] {
                                 
                                 var address = ""
                                 
                                     if placemark.subThoroughfare != nil{
                                         address += placemark.subThoroughfare! + " "
                                     }
                                     
                                     if placemark.thoroughfare != nil {
                                          address += placemark.thoroughfare! + " "
                                     }
                                     
                                     if placemark.subLocality != nil {
                                         address += placemark.subLocality! + " "
                                                        }
                                     
                                     if placemark.subAdministrativeArea != nil {
                                         address += placemark.subAdministrativeArea! + " "
                                                        }
                                     
                                     if placemark.postalCode != nil {
                                         address += placemark.postalCode! + " "
                                                        }
                                     
                                     if placemark.country != nil {
                                         address += placemark.country!
                                                        }
                                     print(address)
                                    self.favoriteAddress = address


                                  let favoritePlace = FavoritePlace(lat: lat ?? 0.0, long: long ?? 0.0, speed: speed ?? 0.0, course: course ?? 0.0, altitude: altitude ?? 0.0, address: self.favoriteAddress ?? "no address found")

                                         self.favoritePlaces?.append(favoritePlace)
                                    print("Data Added Successfully")
                                  self.saveData()
                                  self.navigationController?.popToRootViewController(animated: true)
                                 }
                           
                            }
                    }
            }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alert.addAction(cancelAction)
                alert.addAction(addAction)
          
             present(alert, animated: true, completion: nil)
         }
        
    }

    //MARK: extension for location manager
    extension addPlaceViewController: CLLocationManagerDelegate {
         func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations.last! as CLLocation
            let currentLocation = location.coordinate
            let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 15000, longitudinalMeters: 15000)
            mapObject.setRegion(coordinateRegion, animated: true)
            // automatically updates location
            locationManager.stopUpdatingLocation()
         }
         
         func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error Occured: \(error.localizedDescription)")
         }
    }
