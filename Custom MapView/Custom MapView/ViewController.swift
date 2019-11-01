//
//  ViewController.swift
//  Custom MapView
//
//  Created by logesh on 10/28/19.
//  Copyright © 2019 logesh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController{

    @IBOutlet weak var getLocation: UITextField!
    @IBOutlet weak var addressMapView: MKMapView!
    @IBAction func getDirections(_ sender: Any) {
        
        getCoordinate(addressString: getLocation.text ?? "Union Station") { location,error in
            if error == nil {
                 self.getLocation.endEditing(true)
                 self.addressMapView.removeAnnotations(self.addressMapView.annotations)
                 self.updateMapRegion(Coordinates: location)
                 self.addAnnotation(Coordinates: location)
                 self.getDirection(start: self.currentLocation!, Finish: location)
            }
            else{
                let alert = UIAlertController(title: "UnIdentified Location", message: "Given Location is unidentifiable Please be more Specific", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
     var locationManager = CLLocationManager()
    var currentLocation : CLLocationCoordinate2D?

    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addressMapView.delegate = self
        locationManager.startUpdatingLocation()
        self.requestLocationAuthorisation()
    }

    //MARK: Functions
    func updateMapRegion(Coordinates : CLLocationCoordinate2D)  {
        let region = MKCoordinateRegion(center: Coordinates, latitudinalMeters: 250, longitudinalMeters: 250)
        addressMapView.region = region
    }
    
    func addAnnotation(Coordinates : CLLocationCoordinate2D)
    {
        
        let annotationPin = MKPointAnnotation()
        annotationPin.coordinate = Coordinates
        annotationPin.title = self.getLocation.text
        addressMapView.addAnnotation(annotationPin)
    }
    
    func getDirection(start : CLLocationCoordinate2D , Finish : CLLocationCoordinate2D)  {
        let startMapItem = MKMapItem(placemark: MKPlacemark(coordinate: start))
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: Finish))
        let directionRequest = MKDirections.Request()
        directionRequest.source = startMapItem
        directionRequest.destination = destinationItem
        directionRequest.requestsAlternateRoutes = true
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {response,error in
            if let error = error as? MKError {
                print(error)
                print("Error in identifying Direction")
            }
            if let response = response {
                let routes = response.routes
                print(routes.count)
                for route in routes{
                    print(route.distance)
                    print(route.expectedTravelTime/3600)
                    let polyline = route.polyline
                    self.addressMapView.addOverlay(polyline)
                }
            }
            
        })
    }
    
    
    


  
    
}

//MARK: - Textfield Delegate Extension
extension ViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.getLocation.endEditing(true)
    }
    
    
    
}

//MARK: - Core Location Extension
extension ViewController : CLLocationManagerDelegate
{

    //MARK: - Coordinates Retrival Function
    func getCoordinate( addressString : String,
                        completionHandler: @escaping(_ location: CLLocationCoordinate2D,_ error : NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            else{
                print(error)
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func requestLocationAuthorisation(){
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||  CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestLocation()
        } else {
            print("PLease turn on location services or GPS")
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let userLocation:CLLocation = locations[0]
        let latitude: CLLocationDegrees = userLocation.coordinate.latitude
        let longitude: CLLocationDegrees = userLocation.coordinate.longitude
        let location: CLLocation = CLLocation(latitude: latitude,longitude: longitude)
        currentLocation = location.coordinate
        locationManager.stopUpdatingLocation()

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Error")
       }

}

//MARK: - Map Delegate Function
extension ViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyLine = overlay as? MKPolyline{
            let polyLineRenderer = MKPolylineRenderer(polyline: polyLine)
            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineWidth = 3.0
            return polyLineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}

