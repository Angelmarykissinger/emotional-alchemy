import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/profile_screen.dart';
import 'screens/profile_setup_screen.dart';

import 'package:provider/provider.dart';
import 'theme.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
      ],
      child: const EmotionalAlchemyApp(),
    ),
  );
}

class EmotionalAlchemyApp extends StatelessWidget {
  const EmotionalAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Emotional Alchemy",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.pastelTheme,

      /// ✅ Routes (Optional but useful)
      routes: {
        "/login": (_) => const LoginScreen(),
        "/home": (_) => const MainNavigation(),
        "/profile": (_) => const ProfileScreen(),
        "/setupProfile": (_) => const ProfileSetupScreen(),
      },

      /// ✅ Auth Wrapper Controls Everything
      home: const AuthWrapper(),
    );
  }
}

/// ✅ FINAL AUTH WRAPPER (Fixes all looping issues)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        /// Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// Not Logged In → Login Screen
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        /// Logged In → Check Profile Exists
        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .get(),
          builder: (context, profileSnap) {
            if (!profileSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            /// First Time User → Setup Profile Screen
            if (!profileSnap.data!.exists) {
              return const ProfileSetupScreen();
            }

            /// Profile Exists → Main App Navigation
            return const MainNavigation();
          },
        );
      },
    );
  }
}
