# Corona-Kontakttagebuch

## Abstract
With our Contact diary its possible to safe the last location you have been and the persons you have met for 14 Days. After that the data will be deleted.

## Team Members
- Lukas Zahel - lz026
- Nicole Zeh - nz015
- Joel Dettinger - jd087

## Description
With the help of our app the encounter of people can be registered in a daily diary with the location where you met them.  In case of a Corona infection the encounters can be tracked back to the location with the address and to every person you met.
You save every person with their phone number so you can easily contact them. Also you can provide whether you have worn a mask or not and how long you have met the person or stayed on the location.
The location can be seen on the map.

## Used Categories
- Location and Sensors: GPS
- Date Storage: Store app local data using SQL, Key/Value
- Networking: Consume API, Parse JSON

## Structure

### Model
In the model every basic data gets implemented and the api calls get provided.
We use following APIs:

To get a location from google maps by an search string:
- SearchAPI: https://developers.google.com/places/web-service/search

To translate the users coordinates into a address.
- Geocoding API: https://developers.google.com/maps/documentation/geocoding/start

Both APIs are used to provide a location with coordinates, so you can exactly track your encounter.

### View
In the view we provide global views like specific table view cells. So we can reuse them where ever we need.
Also we provide a custom table view class so we can resize the table view dynamically to its content.

### Controler 
In the controller we provide all view controlles to our views. 
These are:
- AddEncounter: To create a new encounter with date, time, mask, optional persons, optional location and the map 
- AddPerson: To add a person with name and optional phone number.
- AddLocation: To add a location with name, address and optional the coordinates
- Locations: To see all locations you have encountered somebody
- Persons: To see all persons you met with the encounters you have with them
- Encounters: To see encounters
- EncounterDetail: To see the details of every encounter

To create a encounter you have to either provide location or persons or both of them. 

## Logik
Everything gets stored in the core data. With every start of the app the core data gets filter to every encounter which is older the 14 days will be deleted. If you delete all encounter with a specific person also the person will be removed from the database. Same for the location.
To get the exact coordinates and address for your location you can either use your current location or search via the api for one.

## Design
In our app, we use rounded shapes throughout. The cells in each TableView follow the same pattern. The first screen is used to create an encounter, allowing the user to create an entry as quickly and easily as possible. The colors are limited to a Primary (yellow: FFE067) and Secondary (blue: B1E4F4) color. Also, people entries are always associated with the color blue. The icons used have been imported from the Material Design Library.

## SetUP
Before starting the app, make sure to simulate a Location. 
