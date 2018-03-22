iOS Mobile Development - Helping Hands - Team 13

Team Members: Tracy Nguyen
			  Bryan Bernal
			  Manasa Tipparam
			  Ozone Kafley

IMPORTANT NOTES:

* If there are import errors, please make sure to run "pod install" in the project directory.

* Also, please open the project using the .xcworkspace instead of .xcodeproj.

Contributions:

Tracy Nguyen (25%)
* Search Page - filtering and search implementation
* QR Code - generation based on jobID string hash
* Camera QR Scanner - preview layer scanner to decrypt QR Code and verify
* Payment Screens - rating custom controller (unimplemented credit card SDK)
* SideBar - creation of interface and connection to navigation
* Firebase Database - storage and retrieval of entities

Manasa Tipparam (25%)
* Launch splash screen
* Login screen
* Registration screen
* Connection to Firebase Database for Authentication and user data storage
* User permissions - Camera, Photo Library, Location
* Merging fixes

Bryan Bernal (25%)
* User Model Page
* User Model Edit Page
* Job Model Page
* Job Model Edit Page
* Event Model Page
* Event Model Edit Page
* Bug fixes for segues/actions

Ozone Kafley (25%)
* Jobs Near You
* Events Near You 
* Add Job
* Add Event screens 
* Contact us page

Deviations:
* We had originally planned on just using the CoreData for alpha, but we decided to use Firebase as our database instead. This complicated a few things and made connecting data at the end a bit rough, so we currently are displaying dummy data for two or three screens.

* The BrainTree credit card SDK was a bit more complicated than anticipated to implement, so we are going to implement that in the Beta when the database is fully connected and we create a web server for the credit card processing.

* We have decided to finalize the database entities and attributes and fully connect them before deciding on which options/settings are viable and useful for the Settings screen, so that is not yet implemented for alpha and is moved to beta.

* We are also in the process of finalizing a color scheme, so the night mode button will probably be implemented in the beta or final instead of alpha.


### Outside Components ###
Check Box
Horizontal Review Stack
SWRevealViewController Sidebar
Firebase Database

