BookSwap is a mobile application that enables students to list, browse, and exchange textbooks with their peers. Built with Flutter and Firebase, it provides real-time synchronization, user authentication, and an intuitive interface for managing book listings and swap offers.

## Features

### Authentication
- user signup with email and password
- email verification required before login
- secure authentication via firebase auth
- user profile management

### Book Listings
- create new book listings with title, author, condition, and cover image
- browse all available books in the marketplace
- edit your own book listings
- delete books you no longer want to list
- real-time updates across all devices

### Swap Management
- send swap requests to book owners
- receive and manage incoming swap offers
- accept or reject swap requests
- track swap status (pending, accepted, rejected)
- cancel pending swap offers

### Messaging
- chat with other users about swap offers
- real-time message synchronization
- view chat history with all users

### Settings
- toggle notification preferences
- view profile information
- logout functionality

## Architecture

```
lib/
├── models/              # data models
│   ├── book.dart
│   ├── chat_message.dart
│   ├── swap_offer.dart
│   └── user.dart
├── providers/           # state management
│   └── swap_provider.dart
├── screens/             # ui screens
│   ├── auth/
│   ├── home/
│   ├── chat/
│   └── settings/
├── services/            # business logic
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── notification_service.dart
├── widgets/             # reusable components
└── utils/               # constants and validators
```

### Architecture Diagram

![alt text](<Architecture.png>)

## Prerequisites

Before you begin, ensure you have the following installed:
- flutter sdk (version 3.0 or higher)
- dart sdk (version 2.17 or higher)
- android studio or xcode (for emulators)
- a firebase account
- git

To verify your flutter installation: flutter doctor

## Installation

### Step 1: Clone the Repository
git clone https://github.com/lilalajemima/bookswap.git
cd bookswap


### Step 2: Install Dependencies
flutter pub get

### Step 3: Configure Firebase
Follow the firebase setup instructions below before running the app.

## Firebase Setup

### 1. Create Firebase Project
1. go to [firebase console](https://console.firebase.google.com/)
2. click "add project"
3. enter project name: "bookswap"
4. disable google analytics (optional)
5. click "create project"

### 2. Register Your App

#### For Android:
1. in firebase console, click android icon
2. enter package name: `com.example.bookswap`
3. download `google-services.json`
4. place file in `android/app/`
5. update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```
6. update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### For iOS:
1. in firebase console, click ios icon
2. enter bundle id: `com.example.bookswap`
3. download `GoogleService-Info.plist`
4. place file in `ios/Runner/`

### 3. Enable Authentication
1. in firebase console, go to authentication
2. click "get started"
3. enable "email/password" sign-in method

### 4. Create Firestore Database
1. in firebase console, go to firestore database
2. click "create database"
3. start in test mode (change to production rules later)
4. choose a location close to your users
5. click "enable"

### 5. Set Up Firestore Security Rules
Replace the default rules with:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // books collection
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.ownerId;
    }
    
    // swap offers collection
    match /swap_offers/{offerId} {
      allow read: if request.auth != null && 
                     (request.auth.uid == resource.data.senderId ||
                      request.auth.uid == resource.data.recipientId);
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
                       request.auth.uid == resource.data.recipientId;
      allow delete: if request.auth != null &&
                       request.auth.uid == resource.data.senderId;
    }
    
    // chats collection
    match /chats/{chatId} {
      allow read, write: if request.auth != null &&
                            request.auth.uid in resource.data.participants;
    }
    
    // messages collection
    match /chats/{chatId}/messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
  }
}
```

### 6. Initialize Firebase in Your App
The app is already configured to use firebase so after  flutterfire cli is installed:
dart pub global activate flutterfire_cli
flutterfire configure


## Running the App

### On Android Emulator
1. start android studio
2. open avd manager
3. create/start an emulator
4. run the app: flutter run

### On iOS Simulator
1. open xcode
2. open simulator from xcode menu
3. run the app:
flutter run

### On Physical Device
1. enable developer mode on your device
2. connect device via usb
3. run:
flutter devices
flutter run -d <device-id>

## State Management

This app uses the Provider package for state management. provider was chosen for its simplicity and integration with flutter's widget tree.

### Key Providers:
- SwapProvider: manages book listings, swap offers, and their real-time updates

### How It Works:
1. providers are initialized at app startup in `main.dart`
2. screens listen to provider changes using `Consumer` or `Provider.of`
3. when data changes in firebase, streams automatically update the provider
4. provider notifies all listening widgets to rebuild
5. ui reflects the latest data without manual refresh

Example:
```dart
// listening to changes
Consumer<SwapProvider>(
  builder: (context, swapProvider, child) {
    return ListView.builder(
      itemCount: swapProvider.myBooks.length,
      itemBuilder: (context, index) {
        return BookCard(book: swapProvider.myBooks[index]);
      },
    );
  },
)
```

## Database Schema

### Firestore Collections

#### 1. users

users/{userId}
email: string, displayName: string, emailVerified: boolean, createdAt: timestamp, swapNotifications: boolean,  messageNotifications: boolean

#### 2. books
books/{bookId}
title: string, author: string, condition: string (new, like new, good, used), imageUrl: string (base64 or url), ownerId: string, ownerName: string, postedAt: timestamp.swapStatus: string (null, pending, accepted, rejected)


#### 3. swap_offers

swap_offers/{offerId}
bookId: string, bookTitle: string,  senderId: string,  senderName: string, recipientId: string, recipientName: string, status: string (pending, accepted, rejected),createdAt: timestamp


#### 4. chats
chats/{chatId}
participants: array[userId1, userId2], lastMessage: string, lastMessageTime: timestamp, lastSenderId: string, lastSenderName: string

#### 5. messages
chats/{chatId}/messages/{messageId}
chatId: string, senderId: string, senderName: string, message: string, timestamp: timestamp


### Common Issues

Issue: Firebase not initialized
- solution: ensure `google-services.json` (android) or `GoogleService-Info.plist` (ios) is in the correct location
- run `flutterfire configure` again

Issue: Email verification not working
- check firebase console authentication settings
- ensure email/password provider is enabled
- check spam folder for verification emails

Issue: Books not appearing in feed
- verify firestore security rules allow read access
- check firebase console for created documents
- ensure user is authenticated

Issue: Real-time updates not working
- verify internet connection
- check firestore security rules
- ensure streams are properly listened to in code

Issue: Build fails on iOS
- run `cd ios && pod install`
- clean build: `flutter clean && flutter pub get`
