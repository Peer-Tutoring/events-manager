# Events Manager

A Flutter app for creating, viewing, and managing events with Firebase for user authentication and data storage.

## Features

- **User Authentication**: Sign up, log in, and log out using Firebase Authentication.
- **Event Creation**: Users can add events with a name, description, location, start and end times, and a category (each category has its own image).
- **Event Sorting**: Events are sorted by date on the home screen.
- **Password Management**: Change password feature in settings.

## Setup Instructions

### Prerequisites

- **Flutter SDK**: Install from [Flutter's website](https://flutter.dev/docs/get-started/install).
- **Firebase Project**: Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).

### Steps

1. **Clone the Repo**:

   ```bash
   git clone https://github.com/your-username/events-manager.git
   cd events-manager
   ```

2. **Firebase Setup**:

   - Go to your Firebase project and add an Android app (and/or iOS app if testing on iOS).
   - Register your app package name (e.g., `com.example.events_manager`).
   - Download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) file.
   - Place `google-services.json` in `android/app` and `GoogleService-Info.plist` in `ios/Runner`.
   - Enable **Authentication** and **Cloud Firestore** in the Firebase Console.
   - Follow [FlutterFire setup](https://firebase.flutter.dev/docs/overview) to complete Firebase integration.

3. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

## Usage

- **Sign Up**: Register with first and last name, email, and password. Name details are saved in Firestore.
- **Add Events**: Add events with details. Each event category shows a unique image.
- **View Events**: Events are displayed on the home screen, sorted by date.
- **Settings**: Go to settings to change the password.

## Dependencies

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `flutter_riverpod`
