# tinder-clone-ios-public
Tinder clone application written using SwiftUI, Firebase, CoreData, Swift Package Manager and iOS 15 technologies with an MVVM architectural pattern. Below a more detailed description of the app features.

##Login screen
Only Google Sign in is allowed. Once the user has logged in, the app will perform a check to decide if the user has already created a profile, if that's the case, he will be redirected to the Home screen, otherwise the Create Profile screen will be shown for the user to complete his profile information before proceding to use the application.

##Create Profile screen
In this screen the user will be required to complete the following actions:
* Add at least two profile pictures. This can be obtained through either the phone's photo library or the device camera. The necessary permissions are requested accordingly.
* The user bio is optional, it can contain up to 500 characters. The remaining characters will be shown to the user as he types in the text editor.
* The user name
* The user's birthday. This will be used to calculate his age accordingly.
* The user's gender (to simplify profile fetching and the matching algorithm only two options are available although more options could be added).
* The user interests: his own gender, the opposite, or both.

##Home screen
Here the user will be able to browse trough profiles and either swipe left or right on them in a Tinder-like fashion. Both swipe and button click to perform these actions are supported. If a user likes a user that has liked them before, a match showing said user will appear. Once a profile has been liked or disliked it will not be shown again to that user. From here the user can access to:
* The Edit Profile screen
* The Messages Screen

##Edit Profile screen
This is the part that features the most complex backend handling. The user profile images are saved locally with the Firebase server timestamp. Before any download attempt, the local image timestamps will be checked and if they do not match, they will be downloaded. This prevents excessive download every time the user access this screen but nothing has changed since the last time. The appearance is similar to that of the Create Profile Screen but the following properties can not be modified: 
* Name
* Birthday

##Message screen
Here the user will be able to see his matches and access the corresponding Chat screen to send them messages.

##Chat Screen
Here the user will be able to send messages to his matches and they will be updated in real time using Firebase snaphot listeners.

