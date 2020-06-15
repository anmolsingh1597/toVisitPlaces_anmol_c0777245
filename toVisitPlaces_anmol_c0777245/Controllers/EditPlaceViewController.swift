//
//  EditPlaceViewController.swift
//  toVisitPlaces_anmol_c0777245
//
//  Created by Anmol singh on 2020-06-14.
//  Copyright © 2020 Swift Project. All rights reserved.
//

import UIKit
import MapKit

class EditPlaceViewController: UIViewController {
    @IBOutlet weak var mapForEditPlace: MKMapView!
    
    @IBOutlet weak var ZoomStepper: UIStepper!
    var stepperComparingValue = 0.0
    let defaults = UserDefaults.standard
    var editLat: Double = 0.0
    var editLong: Double = 0.0
    var editPlaceIndex: Int?
    var editPlaces: [FavoritePlace]?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        intials()
    }
    
    func intials() {
        //mapviewDelegate
        mapForEditPlace.delegate = self
        
        //Navigation Controller
        self.title = "Drag to edit"
        let add = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnTapped))
        navigationItem.rightBarButtonItem = add
        // Do any additional setup after loading the view.
        
        //MARK: User defaults
        self.editLat = defaults.double(forKey: "editLat")
        self.editLong = defaults.double(forKey: "editLong")


               
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: editLat, longitude: editLong)
        annotation.title = "Drag this to edit"
        mapForEditPlace.addAnnotation(annotation)
       
        
        let latDelta: CLLocationDegrees = 0.05
        let longDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let customLocation = CLLocationCoordinate2D(latitude: editLat, longitude: editLong)
        let region = MKCoordinateRegion(center: customLocation, span: span)
        
        // 4 - assign region to map
        mapForEditPlace.setRegion(region, animated: true)
    }
    
     //MARK:- Stepper value change
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        
        let stepperValue = ZoomStepper.value
                if(stepperValue > self.stepperComparingValue){

                    var region: MKCoordinateRegion = mapForEditPlace.region
                    region.span.latitudeDelta /= 2.0
                    region.span.longitudeDelta /= 2.0
                    mapForEditPlace.setRegion(region, animated: true)
                    self.stepperComparingValue = stepperValue
                }else if(stepperValue < self.stepperComparingValue){

                    var region: MKCoordinateRegion = mapForEditPlace.region
                      region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
                      region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
                      mapForEditPlace.setRegion(region, animated: true)
                    self.stepperComparingValue = stepperValue
                }
        
    }
    
    @objc func doneBtnTapped(){
        let alert = UIAlertController(title: "Alert", message: "Are you sure to save this new location?", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            print(self.mapForEditPlace.annotations[0].coordinate)
            self.edittedData(self.mapForEditPlace.annotations[0].coordinate.latitude, self.mapForEditPlace.annotations[0].coordinate.longitude)
                    
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(addAction)
            alert.addAction(cancelAction)

            present(alert, animated: true, completion: nil)
    }
   
    
    func editData(_ newArray: [FavoritePlace]){
        
        let filePath = getDataFilePath()
                   
                   var saveString = ""
                   
                   for favoritePlace in newArray {
                       saveString = "\(saveString)\(favoritePlace.lat),\(favoritePlace.long),\(favoritePlace.speed),\(favoritePlace.course),\(favoritePlace.altitude),\(favoritePlace.address)\n"
                   }
                   
                   do{
                       try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                   } catch {
                       print(error)
                   }
                   
    }
    
    func getDataFilePath() -> String {
         let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
         
         let filePath = documentPath.appending("/Favorite-Place-Data.txt")
         return filePath
     }
    
    func loadData(){
          editPlaces = [FavoritePlace]()
          
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
                          editPlaces?.append(favoritePlace)
                      }
                  }
                  
              }catch {
                  print(error)
              }
          }
      }
    
    
    func edittedData(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let lat = latitude
        let long = longitude
        
        let speed = CLLocation(latitude: latitude, longitude: longitude).speed
        let course =  CLLocation(latitude: latitude, longitude: longitude).course
        let altitude =  CLLocation(latitude: latitude, longitude: longitude).altitude

        CLGeocoder().reverseGeocodeLocation( CLLocation(latitude: latitude, longitude: longitude) ) { (placemarks, error) in
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
                                 


                                let editPlace = FavoritePlace(lat: lat , long: long , speed: speed , course: course , altitude: altitude , address: address )

                                self.editPlaces?.remove(at: self.editPlaceIndex!)
                                      self.editPlaces?.append(editPlace)
                                 print("Data Added Successfully")
                                self.editData(self.editPlaces!)
                               self.navigationController?.popToRootViewController(animated: true)
                              }

                         }
                 }
         }
    }

    
    


extension EditPlaceViewController: MKMapViewDelegate {
    
       func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
            let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.animatesDrop = true
            pinAnnotation.isDraggable = true
            return pinAnnotation
        }

    
}
