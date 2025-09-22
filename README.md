# Authentication Setup Guide

This guide will help you set up Firebase Authentication for the AI Hair Styler app.

## Prerequisites

1. A Firebase project
2. Flutter development environment
3. Android Studio or VS Code with Flutter extensions

## Firebase Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: "AI Hair Styler" (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication
5. Click "Save"

### 3. Add Android App

1. In the Firebase project overview, click "Add app" and select Android
2. Enter package name: `com.example.flutter_hair_styler` (or your package name)
3. Enter app nickname: "AI Hair Styler Android"
4. Click "Register app"
5. Download the `google-services.json` file
6. Place it in `android/app/` directory

### 4. Add iOS App (if needed)

1. Click "Add app" and select iOS
2. Enter bundle ID: `com.example.flutterHairStyler` (or your bundle ID)
3. Enter app nickname: "AI Hair Styler iOS"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place it in `ios/Runner/` directory

### 5. Generate Firebase Configuration

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Login to Firebase:
   ```bash
   flutterfire login
   ```

3. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```

4. This will automatically update the `firebase_options.dart` file with your project configuration.

## Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Features Implemented

### Login Screen
- Email and password input fields with validation
- Real-time form validation
- Firebase authentication integration
- Error handling with user-friendly messages
- Navigation to signup screen

### Signup Screen
- Full name, email, password, and confirm password fields
- Comprehensive form validation
- Password confirmation matching
- Firebase user creation
- Navigation to login screen

### Custom Input Field Widget
- Reusable text input component
- Floating label design
- Icon support
- Password visibility toggle
- Error state handling
- Focus state management

### Authentication Service
- Firebase Auth integration
- Error handling with localized messages
- User management functions
- Sign in, sign up, and sign out functionality

## Validation Rules

### Email Validation
- Required field
- Valid email format using regex

### Password Validation
- Required field
- Minimum 6 characters

### Full Name Validation
- Required field
- Minimum 2 characters

### Confirm Password Validation
- Required field
- Must match the password field

## Error Handling

The app handles various Firebase Auth errors:
- User not found
- Wrong password
- Email already in use
- Weak password
- Invalid email
- Too many requests
- And more...

## Next Steps

1. Set up your Firebase project following the steps above
2. Update the `firebase_options.dart` file with your actual configuration
3. Test the authentication flow
4. Customize the UI to match your brand
5. Add additional features like password reset, email verification, etc.

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Make sure you've added the `google-services.json` file to the correct location
2. **Build errors**: Run `flutter clean` and `flutter pub get`
3. **Authentication not working**: Check that Email/Password authentication is enabled in Firebase Console
4. **Configuration errors**: Verify your `firebase_options.dart` file has the correct project details

### Getting Help

- Check the [Firebase Documentation](https://firebase.google.com/docs)
- Review the [FlutterFire Documentation](https://firebase.flutter.dev/)
- Check the console for error messages
