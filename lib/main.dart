import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/opportunity_provider.dart';
import 'providers/application_provider.dart';
import 'providers/startup_provider.dart';
import 'providers/bookmark_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/startup/startup_gate.dart';
import 'screens/admin/admin_verify_screen.dart';

void main() async {
  // this has to run before we can talk to Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider lets us put all our providers above the whole app
    // so any screen can read them
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OpportunityProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => StartupProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: MaterialApp(
        title: 'ALU Link',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F6F5C), // deep teal green
            secondary: const Color(0xFFE0A32E), // warm gold accent
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F5F1),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F6F5C),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F6F5C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

// this widget decides which screen to show depending on login state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    var auth = context.watch<AuthProvider>();

    // still waiting to find out if someone is logged in
    if (!auth.authChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // nobody logged in, show the login screen
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    // logged in, send them to the right home screen for their role
    if (auth.isAdmin) {
      return const AdminVerifyScreen();
    } else if (auth.myUser!.role == 'startup') {
      return const StartupGate();
    } else {
      return const StudentHomeScreen();
    }
  }
}
