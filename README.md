# ALU Link

ALU Link is a mobile app that connects ALU students who want internship
experience with student-led startups at ALU. Startups (once verified by an
admin) can post opportunities, and students can search for opportunities,
apply, bookmark ones they like, and track the status of their applications.

Built for the Formative Assignment 2 project.

## Why this app

A lot of ALU students want real experience but it's hard to find it, and a
lot of student startups on campus need help but don't have an easy way to
find students. This app is a small marketplace between the two groups. To
keep the platform trustworthy, any startup has to be approved by an admin
before its opportunities are visible to students, so students aren't
applying to fake or random "startups".

## Main features

- Email/password sign up and login, with a role picker (Student or Startup)
- Startup profile creation + admin verification step before a startup can post
- Startups can post, view and manage opportunities
- Students can search and filter opportunities by category and keyword
- Students can apply with a short cover note
- Students can bookmark opportunities to check later
- Students can track the status of every application they sent (pending,
  accepted, rejected)
- Startups can see everyone who applied and accept or reject them
- Everything updates in real time using Firestore streams, so if a startup
  accepts you, your "My Applications" tab updates without refreshing

## How the app is organized

```
lib/
  main.dart                 - app startup, theme, and the AuthGate router
  constants.dart             - admin email + list of opportunity categories
  models/                     - plain classes for the Firestore data
  providers/                  - ChangeNotifier classes for state management
  screens/
    auth/                     - login and signup
    student/                  - browse, opportunity detail, apply, applications, bookmarks
    startup/                  - startup profile setup, post opportunity, applicants
    admin/                    - startup verification screen
  widgets/                    - small reusable widgets (opportunity card)
```

State management is done with the **provider** package. Each provider
(`AuthProvider`, `OpportunityProvider`, `ApplicationProvider`,
`StartupProvider`, `BookmarkProvider`) wraps Firebase calls and notifies the
UI when data changes, so screens don't talk to Firebase directly.

## Firestore structure

- `users/{uid}` - name, email, role ("student" or "startup"), bookmarks list
- `startups/{uid}` - startup profile info + `isVerified` (bool)
- `opportunities/{id}` - one posted internship/gig, linked to a startupId
- `applications/{id}` - one student's application to one opportunity, with a status

Security rules are in [`firestore.rules`](firestore.rules).

## Running the project

This project was scaffolded but does **not** come with a real Firebase
project connected yet — `lib/firebase_options.dart` currently has
placeholder values. To run it:

1. Make sure you're logged into **your own** Firebase account, not anyone
   else's:
   ```
   firebase login
   ```
2. Install the FlutterFire CLI if you don't already have it:
   ```
   dart pub global activate flutterfire_cli
   ```
3. From this project folder, run:
   ```
   flutterfire configure
   ```
   and pick (or create) your own Firebase project. This will overwrite
   `lib/firebase_options.dart` with your real config.
4. In the Firebase console, turn on **Email/Password** sign-in under
   Authentication, and create a **Firestore Database** (start in test mode,
   or paste in `firestore.rules`).
5. Open `lib/constants.dart` and change `adminEmail` to whichever email
   you want to use as the admin account (sign up with that email in the
   app to access the admin verification screen).
6. Run the app on an emulator or a real device:
   ```
   flutter pub get
   flutter run
   ```

## Testing

`flutter test` runs a model test and a widget test that don't require
Firebase to be running (see `test/widget_test.dart`).
