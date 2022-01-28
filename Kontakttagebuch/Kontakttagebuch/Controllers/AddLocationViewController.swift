//
//  addLocationViewController.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 18.01.21.
//

import UIKit
import CoreLocation

// hands the location to parent
protocol AddLocationDelegate{
    func addLocation(location: Location)
}

class AddLocationViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    //------- UI Def ---------------------------------
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //------- Props -----------------------------------
    
    //GPS
    let locationManger = CLLocationManager()
    var location: CLLocation?
    var lastLocationError: Error?
    var isUpdatingLocation = false
    
    //API
    let classLocations = Locations()
    var searchResults:  [Locations.FormattedAddress] = []
    
    //Vars
    var currentLocation: Location?
    var selectedLocation: Location?
    var addLocationDelegate: AddLocationDelegate?
    
    var nameIsEmpty = true
    var addressIsEmpty = true
    
    
    //------- Lifecycle -----------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("-------- load AddLocation --------")
        
        DispatchQueue.main.async {
            self.findLocation()
        }
        
        tableView.register(LocationTableViewCell.nib(), forCellReuseIdentifier: LocationTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        
    }
    
    //------- Logic ---------------------------------------
    
    // sets the name and address in UI
    func updateSelectedLocation(){
        
        // don't change name of user input if no one is given
        if (selectedLocation?.name.count)! > 0 {
            textFieldName.text = selectedLocation?.name
            textFieldAddress.text = selectedLocation?.address
        }else{
            textFieldAddress.text = selectedLocation?.address
        }
        
    }
    
    // convert the FormattedAddress Object from seearchLocation Api into the usable Location object
    func convertApiAddressIntoLocation(apiObject: Locations.FormattedAddress) -> Location {
        
        let newName = apiObject.name
        let newAddress =  apiObject.formatted_address
        let newLatitude = apiObject.geometry.location.lat
        let newLongitude = apiObject.geometry.location.lng
        
        let newLocation = Location(id: UUID(), name: newName, address: newAddress, lat: newLatitude, lng: newLongitude)
        
        return newLocation
        
    }
    
    //------- Buttons/ Textfields  ------------------------
    
    // set borader color back to normal if user enters something
    @IBAction func textFieldNameChange(_ sender: UITextField) {
        if(nameIsEmpty && textFieldName.text?.count ?? 0 > 0){
            nameIsEmpty = false
            textFieldName.layer.borderWidth = 0
        }
    }
    
    @IBAction func textFieldAddressChange(_ sender: UITextField) {
        if(addressIsEmpty && textFieldAddress.text?.count ?? 0 > 0){
            addressIsEmpty = false
            textFieldAddress.layer.borderWidth = 0
        }
    }
    
    
    
    @IBAction func addCurrentLocationBtn(_ sender: Any) {
        
        selectedLocation = currentLocation
        updateSelectedLocation()
        
    }
    
    @IBAction func addLocationBtn(_ sender: UIButton) {
        
        if(textFieldName.text?.count ?? 0 < 1){
            textFieldName.layer.borderWidth = 3
            textFieldName.layer.cornerRadius = 5
            textFieldName.layer.borderColor = UIColor.red.cgColor
            
            nameIsEmpty = true
            
            return
        }
        else if(textFieldAddress.text?.count ?? 0 < 1){
            textFieldAddress.layer.borderWidth = 3
            textFieldAddress.layer.cornerRadius = 5
            textFieldName.layer.borderColor = UIColor.red.cgColor
            
            addressIsEmpty = true
        }
        else{
            
            if (selectedLocation != nil){
                
                var addedName: String
                
                if let newName = textFieldName.text{
                    
                    addedName = newName
                    
                    let addedAddress = selectedLocation?.address
                    let addedLat = selectedLocation!.lat
                    let addedLng = selectedLocation!.lng
                    
                    let addedLocation = Location(id: UUID(), name: addedName, address: addedAddress!, lat: addedLat, lng: addedLng)
                    
                    print("add Location: name = ", selectedLocation!.name," addresse = ", selectedLocation!.address )
                    
                    addLocationDelegate?.addLocation(location: addedLocation)
                    
                    navigationController?.popViewController(animated: true)
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    //------- GPS  ------------------------------------------
    
    func findLocation(){
        // 1. Get users permission
        print("going to find location")
        let authorizationStatus = locationManger.authorizationStatus
        if authorizationStatus == .notDetermined {
            //no user permission
            return
        }
        // 2. report to user if permission denied
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            reportLocationServicesError()
            return
        }
        
        // 3. start / stop finding location
        if isUpdatingLocation{
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
    }
    
    // Location Manager
    
    func stopLocationManager(){
        if isUpdatingLocation{
            locationManger.stopUpdatingLocation()
            locationManger.delegate = nil
            isUpdatingLocation = false
        }
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled() {
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }
    
    // Error handling
    
    func reportLocationServicesError(){
        let alert =  UIAlertController(title: "Oops! Location Services Disabled.", message: "Please go to Settings > Privacy to enable location services for this app.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //------- API  -----------------------------------------
    
    // Gets the Address with the Current GPS coordinates
    
    func getAddressByLocation(lat:Double,lng:Double) -> Void{
        
        print("api call locations start in GPS: ", lat, lng)
        
        var address = ""
        let latString = String(format: "%f", lat)
        let lngString = String(format: "%f", lng)
        
        Address().apiCall(lat: latString, lng: lngString){ (addresses) in
            address = addresses.first?.formatted_address ?? "No Address found"
            
            //do something when the address arrivved
            DispatchQueue.main.async {
                
                // setting the current location
                self.currentLocation = Location(id: UUID(), name: "", address: address, lat: lat, lng: lng)
                
                print("currentLocation: \n id: \(String(describing: self.currentLocation?.id)) \n location: \(String(describing: self.currentLocation?.address)) \n latitude: \(String(describing: self.currentLocation!.lat)) \n longitude: \(String(describing: self.currentLocation!.lng))")
            }
        }
    }
    
    // search for Lcoation using the searchText from the user
    
    func searchLocation(searchText: String, searchLat:Double, searchLng:Double) -> Void{
        
        let searchLatStr = String(format: "%f", searchLat)
        let searchLngStr = String(format: "%f", searchLng)
        
        Locations().apiCall(search: searchText,lat: searchLatStr,lng: searchLngStr){ (addresses) in
            
            //do something when the address arrivved
            DispatchQueue.main.async {
                print("API search found \(addresses.count) locations")
                // the reuslt list is handed to tableView
                self.searchResults = addresses
                self.tableView.reloadData()
                
            }
        }
    }
    
//------- TableView  -------------------------------------
    
    // rows number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    //Configure the cell...
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        
        cell.configure(with: searchResults[indexPath.item].name, address: searchResults[indexPath.item].formatted_address)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchBar.text = ""
        
        selectedLocation = convertApiAddressIntoLocation(apiObject: searchResults[indexPath.row])
        
        updateSelectedLocation()
        
    }
    
    //------- Searchbar  ---------------------------------------
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // clear tableview when no text
        if(searchText.count == 0){
            searchResults.removeAll()
            tableView.reloadData()
            return
        }
        
        var lat : Double
        var lng : Double
        
        if let latitude = currentLocation?.lat{
            lat = latitude
        }
        else{
            return
        }
        
        if let longitude = currentLocation?.lng{
            lng = longitude
        }
        else{
            return
        }
        
        if(searchText.count > 0){
            searchLocation(searchText: searchText, searchLat: lat, searchLng: lng)
            
        }
    }
}

//------- GPS extension  ---------------------------------------

extension AddLocationViewController: CLLocationManagerDelegate{
    
    // handle fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error!! locationManager-didFailWithError: \(error) ")
        
        // not a system Error
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        
        lastLocationError = error
        stopLocationManager()
    }
    
    // handle success
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = locations.last!
        
        print("GOT IT!! locationManager-didUpdateLocation: \(String(describing: location))")
        
        let lat = location?.coordinate.latitude ?? 0
        let lng = location?.coordinate.longitude ?? 0
        
        getAddressByLocation(lat: lat, lng: lng)
        
        stopLocationManager()
        
    }
}
