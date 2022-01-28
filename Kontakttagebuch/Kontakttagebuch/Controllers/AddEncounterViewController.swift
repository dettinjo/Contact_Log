//
//  NewEntity-ViewController.swift
//  Kontakttagebuch
//
//  Created by Lukas Zahel on 29.12.20.
//

import UIKit
import CoreGraphics
import MapKit
import CoreLocation
import CoreData

class AddEncounterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, AddPersonDelegate, AddLocationDelegate {
    
    //------- UI Def ---------------------------------
    
    @IBOutlet weak var personTableView: UITableView!
    @IBOutlet weak var personTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var timePickerStart: UIDatePicker!
    @IBOutlet weak var timePickerEnd: UIDatePicker!
    @IBOutlet weak var maskSwitch: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addLocationBtn: UIButton!
    
    
    //------- Props -----------------------------------
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var addedPersons: [Person] = []
    var addedLocation: Location?
    var maskStatus = true
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    //------- Life Cycle -------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //refreshDatabase with valid dates
        refreshDatabase()
        
        //Setup date picker
        setupDatePicker()
        
        //Setup GPS
        locationManager.requestWhenInUseAuthorization()
        
        //Setup Navigation Controller Title
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 30)!]
        
        
        //Setup Table View
        personTableView.register(ButtonTableViewCell.nib(), forCellReuseIdentifier: ButtonTableViewCell.identifier)
        personTableView.register(PersonTableViewCell.nib(), forCellReuseIdentifier: PersonTableViewCell.identifier)
        
        personTableView.dataSource = self
        personTableView.delegate = self
        
        personTableView.layer.borderWidth = 1
        
    }
    
    //------- Buttons -----------------------------
    
    @IBAction func maskSwitched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            maskStatus = true
            print("Mask: ",maskStatus)
        case 1:
            maskStatus = false
            print("Mask: ",maskStatus)
        default:
            maskStatus = true
            break;
        }
    }
    
    
    @IBAction func addLocationBtn(_ sender: Any) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "addLocation") as! AddLocationViewController
        VC.addLocationDelegate = self
        
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        safeAllValues()
        resetAllValues()
    }
    
    //------- TableView ---------------------------
    
    // Row number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 + addedPersons.count
    }
    
    // Config cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let addPerson = personTableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as! ButtonTableViewCell
            return addPerson
        }
        else{
            let personName = personTableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as! PersonTableViewCell
            
            personName.configure(with: addedPersons[indexPath.row-1].name)
            
            return personName
        }
        
    }
    
    
    //Define on cell click functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            print(indexPath.row)
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "addPerson") as! AddPersonViewController
            nextVC.addPersonDelegate = self
            
            self.present(nextVC, animated: true, completion: nil)
        }
        else{
            addedPersons.remove(at: indexPath.row-1)
            tableView.reloadData()
            
        }
    }
    
    //Resize Table View to fit content
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.tableViewHeight?.constant = self.personTableView.intrinsicContentSize.height
    }
    
    //------- Logic -----------------------------------
    
    @IBAction func startTimeChanged(_ sender: Any) {
        timePickerEnd.minimumDate = timePickerStart.date
    }
    
    
    //Get selected Persons
    func addPerson(persons: [Person]) {
        print("arrived in Parent: persons= " ,persons)
        
        self.addedPersons.append(contentsOf: persons)
        
        self.personTableView.reloadData()
    }
    
    //Get selected location
    func addLocation(location: Location) {
        
        addedLocation = location
        setupMap(lat: location.lat!, lng: location.lng!)
        
        print("New added location: ", addedLocation!)
        changeLocationButton()
    }
    
    
    func resetAllValues(){
        addedPersons = []
        
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        addedLocation = nil
        addLocationBtn.setTitle("Add Location", for: .normal)
        let newDate = Date()
        datePicker.setDate(newDate, animated: true)
        timePickerStart.setDate(newDate, animated: true)
        timePickerEnd.setDate(newDate, animated: true)
        maskSwitch.selectedSegmentIndex = 0
        personTableView.reloadData()
        
    }
    
    func setupDatePicker(){
        let minDate = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let maxDate = Date()
        
        self.datePicker.minimumDate = minDate
        self.datePicker.maximumDate = maxDate
    }
    
    func setupMap(lat: Double, lng: Double) {
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        annotation.title = addedLocation?.name
        annotation.subtitle = "Device Location"
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func getTime(start: Date, end: Date) -> Double{
        
        let minutes = Double(Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0)
        print("getTime(): ",minutes)
        return minutes
       
    }
    
    /*
     func getTime() -> Double{
         
         let minutes = Double(Calendar.current.dateComponents([.minute], from: timePickerStart.date, to: timePickerEnd.date).minute ?? 0)
         print("getTime(): ",minutes)
         return minutes
        
     }
     */
    
    func changeLocationButton(){
        addLocationBtn.setTitle("Change Location", for: .normal)
    }
    
    //------- Core Data -----------------------------------
    
    func safeAllValues(){
        
        // check if a Location or a Person is given
        if (addedLocation == nil && addedPersons.count < 1) {
            print("no person or location selected")
            return
        }
        
        //Create new encounter
        let newEncounter = EncounterCD(context: context)
        var encountersCD: [EncounterCD]? = []
        do{ encountersCD = try context.fetch(EncounterCD.fetchRequest())
        }catch{
            print("Failed loading Core Data")
        }
        
        //Fetch persons
        for people in addedPersons{
            var existInCD = false
            for encounter in encountersCD! {
                
                // adds only a persons reference to encounter if already existed in CoreData
                for case let item as PersonCD in encounter.encounterPersons! {
                    if (item.personName! == people.name && item.personNumber! == people.phoneNumber){
                        
                        newEncounter.addToEncounterPersons(item)
                        existInCD = true
                        print("Old Person in CD!!!!")
                    }
                }
            }
            
            // create new Person
            if !existInCD {
                let personCD = PersonCD(context: context)
                personCD.personID = people.id
                personCD.personName = people.name
                personCD.personNumber = people.phoneNumber
                newEncounter.addToEncounterPersons(personCD)
                print("new Person in CD!!!!")
                
            }
        }
        
        //Fetch location
        if(addedLocation != nil){
            
            let locationCD = LocationCD(context: context)
            
            locationCD.locationID = addedLocation?.id
            locationCD.locationName = addedLocation?.name
            locationCD.locationAddress = addedLocation?.address
            
            if(addedLocation?.lat != nil){
                locationCD.locationLatitude = (addedLocation?.lat)!
            }
            if(addedLocation?.lng != nil){
                locationCD.locationLongitude = (addedLocation?.lng)!
            }
            newEncounter.encounterLocation = locationCD
            
            print("Location stored: ", locationCD.locationName ?? "")
        }
        
        //Fetch rest
        newEncounter.encounterID = UUID()
        newEncounter.encounterDate = datePicker.date
        newEncounter.encounterTime = getTime(start: timePickerStart.date , end: timePickerEnd.date)
        newEncounter.encounterMask = maskStatus
        
        do {
            try context.save()
            print("Saved: ", newEncounter)
        } catch {
            print("Failed saving context")
        }
        
    }
    
    func refreshDatabase(){
        //Date two weeks from current date
        let dateTwoWeeks = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        
        //-----Load from core data and compare with date
        do{
            var encountersRefresh: [EncounterCD]? = []
            
            encountersRefresh = try context.fetch(EncounterCD.fetchRequest())
            
            for encounter in encountersRefresh! {
                if encounter.encounterDate! < dateTwoWeeks {
                    self.context.delete(encounter)
                    try context.save()
                    print("Deleted: ", encounter)
                }
            }
        } catch{
            print("Failed deleting outdatet")
        }
    }
}


