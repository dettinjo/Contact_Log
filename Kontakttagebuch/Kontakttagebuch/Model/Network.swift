//
//  Network.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 19.01.21.
//

import Foundation

class Address {
    
    struct FormattedAddress: Decodable {
        var formatted_address: String
    }
    
    struct APIResponse: Decodable {
        var results: [FormattedAddress]
        var status: String
    }
    
    func apiCall(lat: String,lng: String, completionHandler: @escaping ([FormattedAddress]) -> Void){
        print("start apiCall")
        let API_KEY = "AIzaSyBX9CqV8aRYIR7YoNHXLTq9xOuwmziMMhM"
        
        let baseURL = "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + lat + "," + lng + "&key=" + API_KEY
        
        guard let url = URL(string: baseURL)
        else{
            return
        }
        print(url)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            do{
                if let data = data{
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("finished api: " ,response.results.first?.formatted_address ?? "")
                    completionHandler(response.results)
                }
            }
            catch{
                print("Error parsing the JSON")
            }
            
        }.resume()
    }
}

class Locations {
    
    
    struct APIResponse: Decodable {
        var results: [FormattedAddress]
        var status: String
    }
    
    struct FormattedAddress: Decodable {
        var formatted_address: String
        var geometry: Geometry
        var name: String
    }
    
    struct Geometry: Decodable {
        var location: ApiLocation
    }
    
    struct ApiLocation: Decodable {
        var lat: Double
        var lng: Double
    }
    
    
    func apiCall(search: String,lat: String,lng: String, completionHandler: @escaping ([FormattedAddress]) -> Void){
        print("start Location apiCall")
        
        let searchText = search.replacingOccurrences(of: " ", with: "%20")
        let API_KEY = "AIzaSyBX9CqV8aRYIR7YoNHXLTq9xOuwmziMMhM"
        let baseURL = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchText.lowercased())&location=\(lat),\(lng)&radius=10000&key=\(API_KEY)"
        
        let encodedURL = baseURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: encodedURL!)
        else{
            print("Error: cannot create URL")
            return
        }
        print("URL: ",url)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            do{
                if let data = data{
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    completionHandler(response.results)
                }
            }
            catch{
                print("Error parsing the JSON")
                return
            }
        }.resume()
    }
}
