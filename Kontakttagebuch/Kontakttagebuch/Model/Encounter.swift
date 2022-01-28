//
//  Encounter.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 18.01.21.
//

import Foundation
import CoreData

class Encounter {
    var id: UUID
    var location: Location?
    var persons : [Person]? = []
    var date: Date
    var time: Double
    var mask: Bool
    
    init(id: UUID, location: Location?, persons: [Person]?, date: Date, time: Double, mask: Bool) {
        self.id = id
        self.location = location
        self.persons = persons
        self.date = date
        self.time = time
        self.mask = mask
    }
    
}
