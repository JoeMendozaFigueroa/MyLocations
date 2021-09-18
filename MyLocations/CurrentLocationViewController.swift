//
//  ViewController.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/16/21.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    //*/These are the variables that Identify the various buttons and labels on the View Controller*/
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel:UILabel!
    @IBOutlet var tagButton: UIButton!
    @IBOutlet var getButton: UIButton!

    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()//*/This shows the "messageLabel" text*/
    }
    
    //MARK: - VIEW
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: - LABEL DETAILS
    //*/This method takes the location text and replaces the text of the "Longitutde & Latitude" Text Labels*/
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(
                format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(
                format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            //*/ This method of grouped booleans is for the "message label" at the top of the View Controller*/
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    //*/This method changes the "Get Button" label, when the App is searching for a location*/
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    //*/This is the method which for the layout of the physical address, to be placed inside the "address label"*/
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let tmp = placemark.subThoroughfare {
            line1 += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            line1 += tmp
        }
        var line2 = ""
        if let tmp = placemark.locality {
            line2 += tmp + " "
        }
        if let tmp = placemark.administrativeArea {
            line2 += tmp + ""
        }
        if let tmp = placemark.postalCode {
            line2 += tmp
        }
        return line1 + "\n" + line2
    }
    
    @objc func didTimeOut() {
        print("*** Time Out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1,
                userInfo: nil)
            updateLabels()
        }
    }
//MARK: - NAVIGATION
    //*/This method is for the segue controller that takes you to the tag "Location View Controller"*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as!
            LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    //MARK: - ACTIONS
    //*/This is the action method that runs various methods, once you press the "get button" at the bottom of the View Controller*/
    @IBAction func getLocation() {
        //*/This constant & boolean asks the user for otherization to use their current location*/
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
        locationManager.requestWhenInUseAuthorization()
        return
        }
        //*/This boolean will be called if user denise the pop-up screen for authorization to use their location*/
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAler()
        }
        if updatingLocation {
            stopLocationManager()
        } else {
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - CL LOCATION MANAGER DELEGATE
    func locationManager(_ manager:  CLLocationManager, didFailWithError error: Error)
    {
        print("didFailWithEror \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    //*/This method is to convert the longitude & latitudes into a physical address. It has various booleans to porvide/calculate a more accurate location search*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
            }
            //*/This bool is for when you stop the location search*/
            if distance > 0 {
                performingReverseGeocoding = false
            }
            updateLabels()
            
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation) {placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.placemark = places.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                    
                    if let places = placemarks {print("*** Found places: \(places)")
                    }
                }
            }
            else if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10 {
                    print("*** Force done!")
                    stopLocationManager()
                    updateLabels()
                }
            }
        } 
    }
    
    //*/This method is for when the Location calcultor starts searching*/
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }
    
    //*/This method is for when the Location calcultor stops searching*/
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }


    //MARK: - HELPER METHODS
    //*/This method is what informs the user that they have denied authorization for this app to use their location*/
    func showLocationServicesDeniedAler() {
        let alert = UIAlertController(title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }

}

