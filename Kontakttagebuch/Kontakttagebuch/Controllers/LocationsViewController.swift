//
//  LocationsViewController.swift
//  Kontakttagebuch
//
//  Created by Lukas Zahel on 01.02.21.
//

import UIKit
import CoreData

class LocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    //------- Props ------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var locations: [Location] = []
    var locationsCD: [LocationCD]? = []
    
    //------- LifeCycle ------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LocationTableViewCell.nib(), forCellReuseIdentifier: LocationTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        print("------ LocationsViewController ------")
        
        fetchDataFromCoreData()
        
        //Setup Navigation Controller Title
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 30)!]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        fetchDataFromCoreData()
    }
    
    //------- CD ------------------------------
    
    // load locations from Database
    func fetchDataFromCoreData(){
        do{
            locations.removeAll()
            
            self.locationsCD = try context.fetch(LocationCD.fetchRequest())
            
            for location in locationsCD! {
                
                var alreadyExists = false
                
                let newLocation = Location(id: location.locationID!, name: location.locationName!, address: location.locationAddress!, lat: location.locationLatitude, lng: location.locationLongitude)
                
                // don't show same location multiple times
                for appendedLocation in locations {
                    if(appendedLocation.address == location.locationAddress! && appendedLocation.name == location.locationName!){
                        alreadyExists = true
                    }
                    
                }
                
                if !alreadyExists{
                    print(newLocation.name)
                    locations.append(newLocation)
                }else{
                    return
                }
                
                
            }
            
            print("number of locations ",locations.count)
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch{
            print("Failed loading Core Data")
        }
    }
    
    //------- TableView ------------------------------
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    //config cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        
        cell.configure(with: locations[indexPath.row].name, address: locations[indexPath.row].address)
        
        return cell
    }
}
