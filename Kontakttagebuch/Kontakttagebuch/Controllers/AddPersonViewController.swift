//
//  addPerson-ViewController.swift
//  Kontakttagebuch
//
//  Created by Lukas Zahel on 29.12.20.
//

import UIKit
import Network
import Contacts
import CoreData

// pass data to parent
protocol AddPersonDelegate{
    func addPerson(persons: [Person])
}

struct ContactStruct {
    let givenName: String
    let familyName: String
    let number: String
}

class AddPersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    //New Features:
    //TODO: show selected persons after selcting after adding one
    //TODO: show details of Contact (number)
    
    //------- UI Def
    
    @IBOutlet weak var newPersonNumber: UITextField!
    @IBOutlet weak var newPersonName: UITextField!
    @IBOutlet weak var tableViewContact: UITableView!
    @IBOutlet weak var contactSearchBar: UISearchBar!
    
    
    
    //------- Props
    
    var contactStore = CNContactStore()
    var foundContacts = [Person]()
    var filteredArray = [Person]()
    
    //Protocol to pass Data to parent
    var addPersonDelegate: AddPersonDelegate?
    
    var addEncounterViewController:AddEncounterViewController?
    let defaults = UserDefaults.standard
    let arraydefault = [String]()
    
    // all persons selected and added
    var addedPersons: [Person] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //------- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewContact.delegate = self
        tableViewContact.dataSource = self
        contactSearchBar.delegate = self
        
        contactStore.requestAccess(for: .contacts) { (success, error) in
            if success{
                print("Authorizazion Successful")
            }
        }
        fetchContacts()
        loadPersonFromCD ()
        
    }
    
    //------- Logic
    
    //Contacs
    func fetchContacts() {
        
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: key)
        
        do{
            try contactStore.enumerateContacts(with: request) { (contact, stoppingPointer) in
                let name = contact.givenName
                let familyName = contact.familyName
                let number = contact.phoneNumbers.first?.value.stringValue
                
                let cotactToAppend = Person(id: UUID(), name: name + " " + familyName, phoneNumber: number)
                
                self.foundContacts.append(cotactToAppend)
            }
        }
        
        catch {
            foundContacts.removeAll()
        }
        
        filteredArray = foundContacts
        
        tableViewContact.reloadData()
        print("Contacs loaded: " , String(foundContacts.first?.name ?? ""))
        
    }
    
    
    //------- TableView
    
    // row number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredArray.count
    }
    
    // config cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let contactToDisplay = filteredArray[indexPath.row]
        
        cell.textLabel?.text = contactToDisplay.name
        
        return cell
    }
    
    // click handler
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        addedPersons = []
        
        let contactToDisplay = filteredArray[indexPath.row]

        
        tableViewContact.deselectRow(at: indexPath , animated: true)
        
        var checkNumber: String
        
        if contactToDisplay.phoneNumber == nil{
            checkNumber = ""
        }
        else{
            checkNumber = contactToDisplay.phoneNumber!
        }
        
       
        
        newPersonName.text = contactToDisplay.name
        newPersonNumber.text = checkNumber
        
    }
    
    //------- Buttons
    
    // adding Person manually
    @IBAction func savePersonBtn(_ sender: UIButton) {
        
        var newPersName:String
        var newPersNumber:String
        
        if let name = newPersonName.text{
            if let number = newPersonNumber.text{
                
                // no name exist
                if name.count == 0 {
                    newPersonName.layer.borderWidth = 3
                    newPersonName.layer.cornerRadius = 5
                    newPersonName.layer.borderColor = UIColor.red.cgColor
                    return
                }
                
                //   name and no number exist
                if (number.count == 0 && name.count > 0){
                    newPersName = name
                    
                    let person:Person = Person(id: UUID(), name: newPersName, phoneNumber: "")
                    addedPersons.append(person)
                    
                    print("created new person: \(person.name)")
                }
                // number and name exist
                if(name.count > 0 && number.count > 0){
                    newPersName = name
                    newPersNumber = number
                    
                    
                    let person:Person = Person(id: UUID(), name: newPersName, phoneNumber: newPersNumber)
                    addedPersons.append(person)
                    
                    print("created new person: \(person.name)")
                    
                    print("created new person: \(person.name)")
                }
            }
        }
        addPersonDelegate?.addPerson(persons: addedPersons)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    // check user input
    @IBAction func textFieldChanged(_ sender: UITextField) {
        newPersonName.layer.borderWidth = 0
    }
    
    // search in Contacts
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredArray = []
        print(searchText)
        if searchText == ""{
            
            filteredArray = foundContacts
        }
        else {
            for item in foundContacts {
                let fullName = item.name
                if fullName.lowercased().contains(searchText.lowercased()){
                    filteredArray.append(item)
                }
            }
        }
        
        tableViewContact.reloadData()
        
    }
    
    //------ CD
    
    func loadPersonFromCD () {
        
        let entityName = "PersonCD"
        
        let reqest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var bool = false
        
        do{
            let result = try context.fetch(reqest)
            
            for foundPerson in result {
                
                if let objectPerson = foundPerson as? NSManagedObject {
                    
                    let foundName = objectPerson.value(forKey: "personName") as! String
                    let foundNumber = objectPerson.value(forKey: "personNumber") as! String
                    let foundID = objectPerson.value(forKey: "personID") as! UUID
                    
                    let person: Person = Person(id: foundID, name: foundName, phoneNumber: foundNumber)
                    
                    bool = false
                    for contact in filteredArray {
                    
                        if contact.name == person.name && contact.phoneNumber == person.phoneNumber {
                            bool = true
                        }
                    }
                    if(bool == false){
                        filteredArray.append(person)
                    }
                    
                }
            }
            
            
        }
        catch{
            print("Error:", error)
        }
        tableViewContact.reloadData()
    }
    
    
}


