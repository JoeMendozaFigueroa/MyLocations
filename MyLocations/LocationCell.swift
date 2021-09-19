//
//  LocationCell.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/17/21.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //ROUNDED CORNERS FOR IMAGES
        //The below makes the icon image have rounded corners
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //This method returns an image or empty placeholder for the tumbnail image in the "Locations" view controller
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resized(withBounds: CGSize(width: 52, height: 52))
        }
        return UIImage(named: "No Photo")!
    }
    //MARK: - HELPER METHOD
    //This method is for the information inside "Locations" View Controller cell
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            addressLabel.text = text
            } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f",
                                       location.latitude,
                                       location.longitude)
        }
        photoImageView.image = thumbnail(for: location)
    }
}
