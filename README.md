# Events Manager 🎟️

A Flutter app for creating, viewing, and managing events with Firebase for user authentication and data storage.

## Features ✨

- 🔒 **User Authentication**: Sign up, log in, and log out using Firebase Authentication.
- 📅 **Event Creation**: Users can add events with details like name, description, location, start/end times, and category (each category has its own image).
- 🔄 **Event Sorting**: Events are displayed on the home screen, sorted by date.
- 🔑 **Password Management**: Change password feature in settings.

## Getting Started 🚀

### Prerequisites

- **Flutter SDK**: Install from [Flutter's website](https://flutter.dev/docs/get-started/install).
- **Firebase Project**: Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).

### Installation Steps

1. **Clone the Repo**:

   ```bash
   git clone https://github.com/your-username/events-manager.git
   cd events-manager
   ```

2. **Firebase Setup**:

   - In Firebase Console, create a new project and add an Android and/or iOS app.
   - Download `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) and place them in `android/app` or `ios/Runner`, respectively.
   - Enable **Authentication** and **Firestore** in Firebase Console.
   - Follow the [FlutterFire setup guide](https://firebase.flutter.dev/docs/overview) to integrate Firebase.

3. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

## Usage 🎉

- **Sign Up**: Register with your first and last name, email, and password.
- **Add Events**: Add events with specific details. Each category displays a unique image.
- **View Events**: Events are displayed by date on the home screen.
- **Settings**: Change your password from the settings screen.

## Dependencies 📦

- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `flutter_riverpod`
