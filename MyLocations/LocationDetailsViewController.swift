//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/16/21.
//
import CoreLocation
import UIKit
import CoreData


class LocationDetailsViewController: UITableViewController {
    //*/These constant variables are the various items in the "Location Details" View Controller*/
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel:UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var placemark: CLPlacemark?

    var coordinate = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0)
    
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!
    
    var date = Date()
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    /*/This method is deals with the functionality of the main View Controller*/
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            title = "Edit Location"
        }
    descriptionTextView.text = descriptionText
    categoryLabel.text = categoryName
    
    latitudeLabel.text = String(
        format: "%.8f",
        coordinate.latitude)
    longitudeLabel.text = String(
        format: "%.8f",
        coordinate.longitude)
    if let placemark = placemark {
        addressLabel.text = string(from: placemark)
    } else {
        addressLabel.text = "No Address Found"
    }
    
    dateLabel.text = format(date: date)
        //HIDE KEYBOARD
    let gestureRecognizer = UITapGestureRecognizer(
        target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - ACTIONS
    /*/This is the method for when a user selects the done button on the tab bar, it reveals the "Tagged" hud display*/
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view
        else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        let location: Location
        //This boolean changes the text of the hud to say updated when user goes into the edit screen and presses the "Done" button
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalCoreDataError(error)
        }
        
        /*/This constant brings you back to the search location screen after user presses done*/
        let delayInSeconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            hudView.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }

    
    /*/This method hides the keyboard after you select outside the description textfield*/
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 &&
            indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    
    @IBAction func categoryPickerDidPickCategory (_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    //MARK: - HELPER METHODS
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            text += tmp + ", "
        }
        if let tmp = placemark.locality {
            text += tmp + ", "
        }
        if let tmp = placemark.administrativeArea {
            text += tmp + " "
        }
        if let tmp = placemark.postalCode {
            text += tmp + ", "
        }
        if let tmp = placemark.country {
            text += tmp
        }
        return text
    }
    
    private let dateFormatter: DateFormatter =
        {let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }()
    
    /*/This method turns the date integers into a string*/
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    //MARK: - NAVIGATION
    /*/This is the method to segue into the "Category Picker" View Controller*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    //MARK: - TABLE VIEW DELEGATES
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }

}
