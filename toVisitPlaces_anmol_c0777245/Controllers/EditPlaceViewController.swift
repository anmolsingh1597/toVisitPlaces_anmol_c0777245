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
    
    let defaults = UserDefaults.standard
    var editLat: Double = 0.0
    var editLong: Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()

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
        print("\(editLat) : \(editLong)")
               
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

    @objc func doneBtnTapped(){
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EditPlaceViewController: MKMapViewDelegate {
    
       func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           
            let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.animatesDrop = true
            pinAnnotation.isDraggable = true
            return pinAnnotation
        }

    
}
