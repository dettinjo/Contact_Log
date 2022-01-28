//
//  PersonsViewController.swift
//  Kontakttagebuch
//
//  Created by Nicole Zeh on 21.01.21.
//

import UIKit
import CoreData

class PersonsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //------- UI Def
    
    @IBOutlet weak var personTableView: UITableView!
    
    //------- Props
    var copyCD: [Person] = []
    var personCD: [Person] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var foundPersons = [String]()
    
    //------- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        personTableView.reloadData()
        personTableView.register(savedPersonsTableViewCell.nib(), forCellReuseIdentifier: savedPersonsTableViewCell.identifier)
        personTableView.delegate = self
        personTableView.dataSource = self
        
        //Setup Navigation Controller Title
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 30)!]
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadPersonFromCD()
        personTableView.reloadData()
        print("viewDidAppear")
        print(personCD.count)
    }
    
    
    //------- TableView
    
    // row number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        personCD.count
    }
    
    // config cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let customCell = tableView.dequeueReusableCell(withIdentifier: savedPersonsTableViewCell.identifier, for: indexPath) as! savedPersonsTableViewCell
        customCell.layer.cornerRadius = 10
        
        let counter = countEncounters(person: personCD[indexPath.row])
        if counter == 0 {
            deletePersonInCD(person: personCD[indexPath.row])
            personTableView.reloadData()
        }
        
        customCell.confiSavedPersons(personName: personCD[indexPath.row].name, personNumber: personCD[indexPath.row].phoneNumber!, count: counter)
        
        return customCell
    }
    
    //------- Logic
    
    
    func deletePersonInCD(person: Person) {
        
        do{
            let personsDelete: [PersonCD]? = try context.fetch(PersonCD.fetchRequest())
            
            for item in personsDelete! {
                if item.personID == person.id{
                    self.context.delete(item)
                    try context.save()
                    print("Deleted: ", item)
                }
            }
        }
        catch{
            print("Failed deleting Core Data")
        }
        
        personTableView.reloadData()
        
    }
    
    func loadPersonFromCD () {
        
        personCD.removeAll()
        copyCD.removeAll()
        
        let entityName = "PersonCD"
        
        let reqest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do{
            let result = try context.fetch(reqest)
            
            for foundPerson in result {
                
                if let objectPerson = foundPerson as? NSManagedObject {
                    
                    let foundName = objectPerson.value(forKey: "personName") as! String
                    let foundNumber = objectPerson.value(forKey: "personNumber") as! String
                    let foundID = objectPerson.value(forKey: "personID") as! UUID
                    
                    let person:Person = Person(id: foundID, name: foundName, phoneNumber: foundNumber)
                    
                    copyCD.append(person)
                    print("Name Schmischma: ", foundName)
                    
                    
                }
            }
            
            personCD = copyCD
        }
        catch{
            print("Error:", error)
        }
        personTableView.reloadData()
    }
    
    // shows how much encouters with this person are stored
    func countEncounters(person: Person) -> Int{
        var counter = 0
        do{
            var encountersCD: [EncounterCD]? = []
            
            encountersCD = try context.fetch(EncounterCD.fetchRequest())
            for encounterCD in encountersCD! {
                for case let personCD as PersonCD in encounterCD.encounterPersons! {
                    
                    if (personCD.personID == person.id) {
                        counter+=1
                        print("Count: " , counter)
                    }
                }
            }
            
            return counter
            
        }
        catch{
            print("Failed deleting outdatet")
        }
        return counter
    }
    
    
    
    
}
