import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_of_service_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Hair Styler',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(GoogleFonts.roboto),
      darkTheme: buildDarkTheme(GoogleFonts.roboto),
      themeMode: ThemeMode.system,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        IntroScreen.routeName: (_) => const IntroScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        PrivacyPolicyScreen.routeName: (_) => const PrivacyPolicyScreen(),
        TermsOfServiceScreen.routeName: (_) => const TermsOfServiceScreen(),
      },
    );
  }
}
// Screens and theme are defined in their own files.
