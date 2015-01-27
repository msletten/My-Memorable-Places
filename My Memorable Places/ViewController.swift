//
//  ViewController.swift
//  My Memorable Places
//
//  Created by Mat Sletten on 1/22/15.
//  Copyright (c) 2015 Mat Sletten. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet weak var myPlacesMap: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBAction func findMeButton(sender: AnyObject) {
        placeLocation.requestWhenInUseAuthorization()
        placeLocation.startUpdatingLocation()
        //println(placeLocation)
    }
    
    var placeLocation:CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        placeLocation = CLLocationManager()
        placeLocation.delegate = self
        placeLocation.desiredAccuracy = kCLLocationAccuracyBest
        //to add places to the map
        if activePlace == -1 {
            placeLocation.requestWhenInUseAuthorization()
            placeLocation.startUpdatingLocation()
            
        } else {
        
        let lat = NSString(string: myPlacesArray[activePlace]["lat"]).doubleValue
        let lon = NSString(string: myPlacesArray[activePlace]["lon"]).doubleValue
        
        //placesMap setup for picking a starting location
//        var placeLatitude:CLLocationDegrees = 45.090369
//        var placeLongitude:CLLocationDegrees = -93.473214
        
        //Setup for map to auto center according to which row in tableVC is pressed
        var myPlaceLat:CLLocationDegrees = lat
        var myPlaceLon:CLLocationDegrees = lon
        var placeLatDelta:CLLocationDegrees = 0.01
        var placeLonDelta:CLLocationDegrees = 0.01
        var placesMapSpan:MKCoordinateSpan = MKCoordinateSpanMake(placeLatDelta, placeLonDelta)
        var placesMapLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(myPlaceLat, myPlaceLon)
        var placesMapRegion:MKCoordinateRegion = MKCoordinateRegionMake(placesMapLocation, placesMapSpan)
        
        myPlacesMap.setRegion(placesMapRegion, animated: true)
        //add annotations
        var placeLocation = MKPointAnnotation()
        placeLocation.coordinate = placesMapLocation
        placeLocation.title = myPlacesArray[activePlace]["name"]
        myPlacesMap.addAnnotation(placeLocation)
        }
        var longPress = UILongPressGestureRecognizer(target: self, action: "action:")
        longPress.minimumPressDuration = 2.0
        myPlacesMap.addGestureRecognizer(longPress)
        //println(activePlace)
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state  == UIGestureRecognizerState.Began {
        //println("You pressed me babe")
        var userTouch = gestureRecognizer.locationInView(self.myPlacesMap)
        var newCoordinates = myPlacesMap.convertPoint(userTouch, toCoordinateFromView: self.myPlacesMap)
//        var newLocation = MKPointAnnotation()
//        newLocation.coordinate = newCoordinates
//        newLocation.title = "new place"
//        myPlacesMap.addAnnotation(newLocation)
        
        var newPlaceLocation = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        
        CLGeocoder().reverseGeocodeLocation(newPlaceLocation, completionHandler:{(placemarks, error) in
            if (error) {println("Error: \(error)")}
            else {
                //println(placemarks)
                let p = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                var subLocality:String
                var street:String
                var subAdmin:String
                
                if (p.subLocality != nil) {
                    subLocality = p.subLocality
                }
                else {
                    subLocality = ""
                }
                if (p.thoroughfare != nil) {
                    street = p.thoroughfare
                }
                else {
                    street = ""
                }
                if (p.subAdministrativeArea != nil) {
                    subAdmin = p.subAdministrativeArea
                }
                else {
                    subAdmin = ""
                }
                //self.addressLabel.text = "\(place.subLocality)\n\(addressNumber) \(place.thoroughfare)\n\(place.subAdministrativeArea), \(place.administrativeArea)\n\(place.country)"
                var newLocation = MKPointAnnotation()
                newLocation.coordinate = newCoordinates
                var placeTitle = "\(street) \(subLocality) \(subAdmin)"
                if placeTitle == "  " {
                    var addDate = NSDate.date()
                    self.title = "Unknown Location added \(addDate)"
                }
                newLocation.title = placeTitle
                self.myPlacesMap.addAnnotation(newLocation)
                myPlacesArray.append(["name":placeTitle,"lat":"\(newCoordinates.latitude)","lon":"\(newCoordinates.longitude)"])
                println(newLocation)
            }
        })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController.navigationBarHidden = false
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        if segue.identifier == "back" {
//            self.navigationController.navigationBarHidden = false
//        }
//    }
    
    func locationManager(placeLocation: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var userNewLocation:CLLocation = locations[0] as CLLocation
        var newLatitudeDT:CLLocationDegrees = userNewLocation.coordinate.latitude
        var newLongitudeDT:CLLocationDegrees = userNewLocation.coordinate.longitude
        var newLatDelta:CLLocationDegrees = 0.01
        var newLongDelta:CLLocationDegrees = 0.01
        var newMapSpan:MKCoordinateSpan = MKCoordinateSpanMake(newLatDelta, newLongDelta)
        var newMapLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(newLatitudeDT, newLongitudeDT)
        var newMapRegion:MKCoordinateRegion = MKCoordinateRegionMake(newMapLocation, newMapSpan)
        
        myPlacesMap.setRegion(newMapRegion, animated: true)
        placeLocation.stopUpdatingLocation()
        
        CLGeocoder().reverseGeocodeLocation(userNewLocation, completionHandler:{(placemarks, error) in
            if (error) {println("Error: \(error)")}
            else {
                //println(placemarks)
                let place = CLPlacemark(placemark: placemarks?[0] as CLPlacemark)
                var addressNumber:String
                if (place.subThoroughfare != nil) {
                    addressNumber = place.subThoroughfare
                }
                else {
                    addressNumber = ""
                }
                self.addressLabel.text = "\(place.subLocality)\n\(addressNumber) \(place.thoroughfare)\n\(place.subAdministrativeArea), \(place.administrativeArea)\n\(place.country)"
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

