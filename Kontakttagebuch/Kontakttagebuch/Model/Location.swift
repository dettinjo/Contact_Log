//
//  Location.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 18.01.21.
//

import Foundation
import CoreData

class Location {
    var id: UUID
    var name: String
    var address: String
    var lat: Double?
    var lng: Double?
    
    init(id: UUID, name:String, address: String, lat: Double?, lng: Double?) {
        self.id = id
        self.name = name
        self.address = address
        self.lat = lat
        self.lng = lng
    }
}
