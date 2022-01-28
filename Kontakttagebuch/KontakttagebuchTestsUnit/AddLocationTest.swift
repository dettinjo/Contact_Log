//
//  AddLocationTest.swift
//  KontakttagebuchTestsUnit
//
//  Created by Lukas Zahel on 01.02.21.
//

import XCTest
@testable import Kontakttagebuch

class AddLocationTest: XCTestCase {
    
    func testAPIGetLocation(){
        var hasValue1 = false
        var hasValue2 = false
        let apiResponse = Locations()
        
        apiResponse.apiCall(search:"123+main+street", lat: "42.3675294", lng: "-71.186966"){ (addresses) in
            if addresses.count > 0 {
                hasValue1 = true
                print("api provided \(addresses.count) values")
            }else{
                hasValue1 = false
            }
            XCTAssertTrue(hasValue1,"api provided no results" )
        }
        
        apiResponse.apiCall(search:"123+main+street", lat: "wrongInput", lng: "wrongInput"){ (addresses) in
            if addresses.count > 0 {
                hasValue2 = true
                print("api provided \(addresses.count) values")
            }else{
                hasValue2 = false
            }
            XCTAssertFalse(hasValue2 ,"api provided results" )
        }
    }
    
    func testAPIGetAddress(){
        let apiResponse = Address()
        
        // should work
        apiResponse.apiCall(lat: "-33.8599358", lng: "151.2090295"){ (addresses) in
            XCTAssertEqual(addresses.first?.formatted_address, "140 George St, The Rocks NSW 2000, Australia")
        }
       
        //should not work
        apiResponse.apiCall(lat: "-33.8599358", lng: "151.2090295"){ (addresses) in
            XCTAssertNotEqual(addresses.first?.formatted_address, "Disneyland")
        }
        
        
    }
    
    func testconvertApiAddress(){
        
        let apiObj = Locations.FormattedAddress(formatted_address: "140 George St, The Rocks NSW 2000, Australia", geometry: Locations.Geometry(location: Locations.ApiLocation(lat: -33.8599358, lng: 151.2090295)), name: "Museum of Contemporary Art Australia")
        
        let resultObject =  AddLocationViewController().convertApiAddressIntoLocation(apiObject: apiObj)
        
        let name = resultObject.name
        let address = resultObject.address
        let lat = resultObject.lat
        let lng = resultObject.lng
        
        XCTAssertEqual(name, "Museum of Contemporary Art Australia")
        XCTAssertEqual(address, "140 George St, The Rocks NSW 2000, Australia")
        XCTAssertEqual(lat, -33.8599358)
        XCTAssertEqual(lng, 151.2090295)
        
    }
}

