# League of Legends Champions Catalogue

## Project description
A mobile application created in Flutter that serves as an interactive catalogue of League of Legends characters.
It allows users to browse a list of all champions and check their abilities and lore.

## Main Features
* **Character List:** Displays a grid with portraits and basic information about the champions.
* **Details Screen:** A dedicated screen for each character, showing their splash art, spells, and lore.
* **API Integration:** The app communicates with the official Riot Games REST API (Data Dragon), making separate requests for the list and details.
* **Offline Mode:** Thanks to local storage, part of the main character list is saved and displays correctly even without an internet connection.
* **Error Handling & Loading State:** The app shows loading animations and text messages when there is no network connection.
* **Filtering:** Displays list of champions whose name starts with particular letter.
* **Language Switch:** A built-in button that toggles the entire app between Polish and English.
* **Manual Refresh:** Supports the "pull-to-refresh" gesture, allowing users to manually and quickly fetch the latest data from the servers.


## Technologies Used
* Flutter & Dart
* `http` package for handling REST API requests
* `shared_preferences` package for offline mode support
* `google_fonts` package for fonts

## How to Run the Project
1. Download the repository to your local machine.
2. Open the project in a code editor, e.g., Android Studio.
3. Fetch the necessary packages using the terminal command: `flutter pub get`.
4. Run the app on an emulator or a physical device using the command: `flutter run`.