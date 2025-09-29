const String kAppName = 'AI Hair Styler';
const String kAppLink = 'https://example.com/aihairstyler_app';

String buildShareText({String? styleName}) {
  final String headline = styleName == null || styleName.isEmpty
      ? 'Check out my new look!'
      : 'I just tried "$styleName"!';
  return '$headline\n\nCreated with $kAppName.\nTry it now: $kAppLink';
}


