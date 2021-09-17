//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/16/21.
//
import CoreLocation
import UIKit

class LocationDetailsViewController: UITableViewController {
    //These constant variables are the various items in the "Location Details" View Controller
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel:UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0)
    var placemark: CLPlacemark?
    
    //MARK: - ACTIONS
    @IBAction func done() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
}
