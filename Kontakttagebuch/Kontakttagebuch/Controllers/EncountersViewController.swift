//
//  EncountersViewController.swift
//  Kontakttagebuch
//
//  Created by Joel Dettinger on 30.01.21.
//

import UIKit
import CoreData

class EncountersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //------- UI Def
    @IBOutlet weak var dateTableView: UITableView!
    
    //------- Props
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var encounters: [Encounter] = []
    var encountersCD: [EncounterCD]? = []
    
    //------- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Navigation Controller Title
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 30)!]
        
        //Setup Table View
        dateTableView.register(DateTableViewCell.nib(), forCellReuseIdentifier: DateTableViewCell.identifier)
        
        dateTableView.dataSource = self
        dateTableView.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        dateTableView.reloadData()
        fetchDataFromCoreData()
    }
    
    //------- TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        encounters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dateTableView.dequeueReusableCell(withIdentifier: DateTableViewCell.identifier, for: indexPath) as! DateTableViewCell
        
        cell.configure(with: encounters[indexPath.row].date, address: encounters[indexPath.row].location!.name)
        if(encounters[indexPath.row].location?.address == ""){
            var stringPersons = ""
            let array: [Person] = encounters[indexPath.row].persons!
            for item in array {
                stringPersons = "\(item.name) "
            }
            cell.configure(with: encounters[indexPath.row].date, address: stringPersons)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Delete cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let encounter = encounters[indexPath.row]
            encounters.remove(at: indexPath.row)
            deleteEncounter(encounter: encounter)
            dateTableView.reloadData()
        }
    }
    
    //Cell detail view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "detailEncounter") as! EncounterDetailViewController
        VC.passedEncounter = encounters[indexPath.row]
        
        navigationController?.pushViewController(VC, animated: true)
        
        
    }
    
    //------- Logic
    
    //Get all data from Core Data and fetch it to encounter objects
    func fetchDataFromCoreData(){
        encounters = []
        do{
            self.encountersCD = try context.fetch(EncounterCD.fetchRequest())
            
            for encounter in encountersCD! {
                
                var persons: [Person] = []
                
                for case let item as PersonCD in encounter.encounterPersons! {
                    let person = Person(id: item.personID!, name: item.personName!, phoneNumber: item.personNumber)
                    persons.append(person)
                }
                
                var newLocation : Location?
                if let location = encounter.encounterLocation{
                    newLocation = Location(id: location.locationID!, name: location.locationName!, address: location.locationAddress!, lat: location.locationLatitude, lng: location.locationLongitude)
                }else{
                    newLocation = Location(id: UUID(), name: "", address: "", lat: 0, lng:0)
                }
                
                print(newLocation ?? "no location given")
                
                let fetchedEncounter = Encounter(id: encounter.encounterID!, location: newLocation, persons: persons, date: encounter.encounterDate!, time: encounter.encounterTime, mask: encounter.encounterMask)
                
                encounters.append(fetchedEncounter)
            }
            DispatchQueue.main.async {
                self.dateTableView.reloadData()
            }
        } catch{
            print("Failed loading Core Data")
        }
    }
    
    //Delete encounter from core data
    func deleteEncounter(encounter: Encounter) {
        do{
            let encountersDelete: [EncounterCD]? = try context.fetch(EncounterCD.fetchRequest())
            
            for item in encountersDelete! {
                if item.encounterID == encounter.id{
                    self.context.delete(item)
                    if(item.encounterLocation != nil){
                        self.context.delete(item.encounterLocation!)
                    }
                    try context.save()
                    print("Deleted: ", item)
                }
            }
        }
        catch{
            print("Failed deleting Core Data")
        }
    }
    
}


