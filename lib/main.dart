import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'screens/view_image_screen.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on firebase_core.FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  }
  // Enable Crashlytics collection in all builds (including debug)
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // All other Dart errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
      title: 'AI Hair Styler',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(GoogleFonts.roboto),
      darkTheme: buildDarkTheme(GoogleFonts.roboto),
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        IntroScreen.routeName: (_) => const IntroScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ViewImageScreen.routeName: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          final path = args?['imagePath'] as String? ?? '';
          final title = args?['title'] as String? ?? 'Preview';
          return ViewImageScreen(imagePath: path, title: title);
        },
        PrivacyPolicyScreen.routeName: (_) => const PrivacyPolicyScreen(),
        TermsOfServiceScreen.routeName: (_) => const TermsOfServiceScreen(),
      },
    ),
    );
  }
}
// Screens and theme are defined in their own files.
