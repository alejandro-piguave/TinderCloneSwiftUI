# TinderCloneSwiftUI

<p float="left">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/swiping_example.gif" width="250">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/create_profile.gif" width="250" />
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/create_profile_dark.gif" width="250" /> 
</p>

Tinder clone application written using SwiftUI, Firebase, Swift Package Manager and iOS 15 technologies with an MVVM architectural pattern. The app contains localizations for both English and Spanish languages and support for dark mode. Below a more detailed description of the app features.

## Login and Create Profile

<p float="left">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/login_screen.png" width="250">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/create_profile_screen_1.PNG" width="250" />
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/create_profile_screen_dark_1.PNG" width="250" /> 
</p>

Only Google Sign in is allowed. Either of these two actions should be performed:
* **If the user has an account:** Click on the "Sign in with Google" button and enter valid credentials. If the login is sucessful and the account exists, the user will be redirected to the home page, otherwise, an error dialog will apear.
* **If the user doesn't has an account:** Click on the "Create a new account button" to navigate to the "Create Profile" screen.

In the Create Profile screen the user will be required to complete the following actions:
* Add at least two profile pictures. These can be obtained through the phone's photo library or the device camera. The necessary permissions are requested accordingly.
* Provide a user name.
* Provide a birth date. This will be used to calculate their age.
* Provide a gender (in order to simplify profile fetching only two options are available).
* Provide a preference: their own gender, the opposite gender or both.

A bio up to 500 characters is optional. The remaining amount of characters are shown as the user is typing.

Once the information has been filled in and the user clicks on the "Sign Up with Google button", if the user didn't exist before and the creation of the account was successful, the user will be redirected to the home page, otherwise an error dialog will appear.

## Home screen
Here the user will be able to browse through profiles and swipe left or right on them in a Tinder-like fashion. Both swipe and button click to perform these actions are supported. If a user likes a user that has liked them before, a match will be created. Once a profile has been liked or disliked it will not be shown again to that user. From here the user can access to:
* The Edit Profile screen
* The Messages Screen

<p float="left">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/home_screen.PNG" width="250" />
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/home_screen_dark.PNG" width="250" /> 
</p>

## Edit Profile screen
In this screen the user can modify the same fields as in the "create profile" screen except for the name and birth date. Their design is almost identical.

<p float="left">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/edit_profile_screen_1.PNG" width="250" />
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/edit_profile_screen_2.PNG" width="250" /> 
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/edit_profile_screen_dark_1.PNG" width="250" />
</p>

## Messages screen
Here the user will be able to see his matches and access the corresponding Chat screen to send them messages.

<p float="left">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/messages_screen.jpeg" width="250" />
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/messages_screen_dark.PNG" width="250" /> 
</p>

## Chat Screen
Here the user will be able to send messages to his matches and they will be updated in real time using Firebase snaphot listeners.

<p float="left">
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/chat_screen.PNG" width="250" />
  <img src="https://github.com/alejandro-piguave/tinder-clone-ios-public/blob/main/screenshots/chat_screen_dark.PNG" width="250" /> 
</p>


Note: The file "GoogleService-Info.plist" required for the project to work is missing. You will need to connect it to your own Firebase project.
