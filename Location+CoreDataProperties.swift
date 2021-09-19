//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/17/21.
//
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var photoID: NSNumber?
    
    @NSManaged var placemark: CLPlacemark?

}

extension Location : Identifiable {

}
