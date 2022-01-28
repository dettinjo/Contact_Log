//
//  AddPersonTest.swift
//  KontakttagebuchTestsUnit
//
//  Created by Nicole Zeh on 01.02.21.
//
@testable import Kontakttagebuch
import XCTest


class AddPersonTest: XCTestCase {
    
    //Test if person is not in Core Data
    
    func testPersonView()  {
        
        let personViewTest = PersonsViewController()
        let angela:Person = Person(id: UUID(), name: "Angela Merkel", phoneNumber: "1234567")
        
        let result = personViewTest.countEncounters(person: angela)
        
        // no Angela Merkel in Core Data
        XCTAssertEqual(result, 0)
        
        // 5 Angela Merkel in Core Data is false
        XCTAssertNotEqual(result, 5)
        
    }
    
    func testEncounterTime() {
        
        let addEncounterTest = AddEncounterViewController()
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        
        let result = addEncounterTest.getTime(start: startDate, end: endDate)
        
        //  15 min difference
        XCTAssertEqual(result, 15.0)
        
        // no time difference is false
        XCTAssertNotEqual(result, 0.0)
        
    }
    
}
