class Secrets {
  // Use dart-define at build time to override in CI/local without committing real keys
  // Example: flutter run --dart-define=GEMINI_API_KEY=your_real_key
  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
}


