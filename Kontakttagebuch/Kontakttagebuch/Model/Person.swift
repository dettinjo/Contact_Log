//
//  Person.swift
//  Kontakttagebuch
//
//  Created by Lukas Zahel on 29.12.20.
//

import Foundation
import CoreData

class Person {
    var id: UUID
    var name: String
    var phoneNumber: String?
    
    init(id: UUID, name: String, phoneNumber: String?) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
    }
}
