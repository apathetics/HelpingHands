iOS Mobile Development - Helping Hands - Team 13

Team Members: Tracy Nguyen
			  Bryan Bernal
			  Manasa Tipparam
			  Ozone Kafley

IMPORTANT NOTES:

* If there are import errors, please make sure to run "pod install" in the project directory.

* Also, please open the project using the .xcworkspace instead of .xcodeproj.
Contribution:

Tracy Nguyen: (Beta: 30% | Overall: 25%)

Beta
Finish connecting database to all entities and process updates/saves.
Connecting data to inquiry/attend table cells in instances.
Connecting type table under user profile to track jobs/events.

Alpha
Search Page - filtering and search implementation
QR Code - generation based on jobID string hash
Camera QR Scanner - preview layer scanner to decrypt QR Code and verify
Payment Screens - rating custom controller (unimplemented credit card SDK)
SideBar - creation of interface and connection to navigation
Firebase Database - storage and retrieval of entities

Manasa Tipparam: (Beta: 30% | Overall: 25%)

Beta
Day and night color scheme switcher.
Settings page creation.
Fleshing out permissions and settings bundle.
Fixing bugs and broken elements such as navbar.

Alpha
Launch splash screen
Login screen
Registration screen
Connection to Firebase Database for Authentication and user data storage
User permissions - Camera, Photo Library, Location
Merging fixes

Bryan Bernal: (Beta: 30% | Overall: 25%)

Beta
Set up locations in every edit/add page.
Connect location data to create a distance variable.
Constraints and clean-up assistance.

Alpha
User Model Page
User Model Edit Page
Job Model Page
Job Model Edit Page
Event Model Page
Event Model Edit Page
Bug fixes for segues/actions

Ozone Kafley:  (Beta: 10% | Overall: 25%)

Beta
Contact Us - message and email integration.
Revamped the Contact Us page.
Clean up and assistance.

Alpha
Jobs Near You
Events Near You 
Add Job
Add Event screens 
Contact us page

Deviations: 

Credit card implementation turned out to be much harder than we anticipated, so seeing as how it’s only a button press, we figured moving it to final release would make sense.

There’s a few minor bugs having to do with race conditions and loading due to the asynchronous nature of the database calls that we haven’t quite had time to account for yet. We expect this will be relatively easy to fix as we wind up functionality and focus on optimization for data passing. However, because of the race conditions, if the internet is slow or a user clicks too quickly before data is loaded, there is a chance of crashing.

The camera scanning with the QR code is quite difficult to test because of the lack of a camera on the emulator, but as far as we can tell, it works well on an actual device. For the sake of the submission, we’ve put a confirmation button instead on the confirmation screen instead of having to find another phone, install the app, and scan it that way. 

Huge setback because our database on Firebase was wiped out several hours before submission. Bad query error made Google say it reached quota. We had to waste a lot of time inputting more data and moving the database to a backup one.

A lot of the connections in the profile to job tables are incomplete right because of the lack of completion query. Tracy had this written but couldn't quite test/push it because of the database problem.

Bryan also has the explore pins linked to each other geographically, but the database wipe put him back a lot in redoing calculations and messed up a lot of his work.

Lots of minor setbacks and bugs, but overall, the app is for the most part completely connected. Just need to flesh out a lot of the bugs in the final phase as we do a lot of QA and aesthetic enhancements.


### Outside Components ###
Check Box
Horizontal Review Stack
SWRevealViewController Sidebar
Firebase Database

