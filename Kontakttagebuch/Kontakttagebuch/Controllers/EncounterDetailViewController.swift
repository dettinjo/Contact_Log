//
//  EncounterDetailViewController.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 01.02.21.
//

import UIKit
import MapKit

class EncounterDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    //------- UI Def ---------------------------------
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var maskLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var personTableView: SelfSizedTableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locationView: UIView!
    
    //------- Props -----------------------------------
    var persons: [Person] = []
    var passedData: Encounter? = nil
    var passedEncounter: Encounter?
    
    //------- Life Cycle -------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData(encounter: passedEncounter!)
        
        //Setup Table View
        personTableView.register(PersonTableViewCell.nib(), forCellReuseIdentifier: PersonTableViewCell.identifier)
        
        personTableView.dataSource = self
        personTableView.delegate = self
        
        personTableView.layer.borderWidth = 1
    }
    
    //------- TableView ---------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = personTableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as! PersonTableViewCell
        
        cell.configure(with: persons[indexPath.row].name)
        
        return cell
    }
    
    //Resize Table View to fit content
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.tableViewHeight?.constant = self.personTableView.intrinsicContentSize.height
    }
    
    //------- Logic -----------------------------------
    
    func setDate(encounter: Encounter){
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "E, d MMM yyyy"
        dateLabel.text = customFormatter.string(from: encounter.date)
    }
    
    func setTime(encounter: Encounter){
        timeLabel.text = "Met \(Int(encounter.time)) minutes"
    }
    
    func setMask(encounter: Encounter){
        if(encounter.mask){
            maskLabel.text = "Wore a mask"
        }
        else{
            maskLabel.text = "Wore no mask"
        }
    }
    func setLocation(encounter: Encounter){
        if(encounter.location != nil){
            locationNameLabel.text = encounter.location?.address
            locationAddressLabel.text = encounter.location?.name
            
            if encounter.location?.lat != nil && encounter.location?.lng != nil {
                let lat = (encounter.location?.lat)!
                let lng = (encounter.location?.lng)!
                setupMap(lat: lat, lng: lng, name: encounter.location!.name)
            }
        }
        if encounter.location?.lat == 0 {
            locationView.isHidden = true
            mapView.isHidden = true
        }
        
        
    }
    
    //Set annotation on the map
    func setupMap(lat: Double, lng: Double, name: String) {
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        annotation.title = name
        annotation.subtitle = "Device Location"
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func setPerson(encounter: Encounter){
        
        if(encounter.persons != nil){
            for person in encounter.persons!{
                persons.append(person)
            }
        }
    }
    
    //Setup all data
    func setupData(encounter: Encounter){
        setDate(encounter: encounter)
        setTime(encounter: encounter)
        setMask(encounter: encounter)
        setLocation(encounter: encounter)
        setPerson(encounter: encounter)
    }
    
    
}
