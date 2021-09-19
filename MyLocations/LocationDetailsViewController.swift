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
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var addPhotoLabel: UILabel!
    
    @IBOutlet var imageHeight: NSLayoutConstraint!
    
    var image: UIImage?
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
    var observer: Any!
    
    /*/This method is deals with the functionality of the main View Controller*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
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
        //Hides keyboard when user selects outside the text field
    let gestureRecognizer = UITapGestureRecognizer(
        target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()
    }
    
    //This method displays the image inside the "Add Photo" cell and stretches it out, to reveal full photo
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        imageHeight.constant = 260
        tableView.reloadData()
    }
    
    //This method brings you back to the Tag/Edit screen, when a user leaves the app
    func listenForBackgroundNotification() {
       observer = NotificationCenter.default.addObserver(
        forName: UIApplication.didEnterBackgroundNotification,
        object: nil,
        queue: OperationQueue.main) { [weak self] _ in
        if let weakSelf = self {
            if weakSelf.presentedViewController != nil {
                weakSelf.dismiss(animated: false, completion: nil)
            }
            weakSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
    //This method catches any errors and places them into the promt screen
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer!)
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
            location.photoID = nil
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
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
    //This is the TEXT for the pin
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea, separatedBy: " ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        
        return line
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
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }

}
//MARK: - END OF CLASS


extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - IMAGE HELPER METHODS
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - IMAGE PICKER DELEGATES
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    //This method is for the "Cancel" tab above the picture selecter
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //This method allows you to selct a picture from the library
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    //This method is for the Photo Menu & its actions
    func showPhotoMenu() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        let actCancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        alert.addAction(actCancel)
        
        let actPhoto = UIAlertAction(
            title: "Take Photo",
            style: .default) {_ in self.takePhotoWithCamera()
        }
        
        let actLibrary = UIAlertAction(
            title: "Choose From Library",
            style: .default) {_ in
            self.choosePhotoFromLibrary()
        }
        
        present(alert, animated: true, completion: nil)
    }
}
