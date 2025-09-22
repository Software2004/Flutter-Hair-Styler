import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const String routeName = '/privacy-policy';

  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Privacy Policy')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '''At AI Hair Styler, we take your privacy seriously. This Privacy Policy explains how we collect, use, and protect your personal information.

1. Information We Collect
- Photos you upload for hairstyle previews
- Device information for app functionality
- Usage data to improve our services

2. How We Use Your Information
- To provide hairstyle preview services
- To improve our AI algorithms
- To maintain and enhance the app

3. Data Storage and Security
- All photos are processed locally on your device
- We use industry-standard security measures
- Your data is never sold to third parties

4. Your Rights
- Access your personal data
- Request data deletion
- Opt-out of data collection

5. Third-Party Services
We use the following third-party services:
- Analytics tools
- Cloud storage providers
- Payment processors

6. Children's Privacy
Our service is not intended for children under 13.

7. Changes to Privacy Policy
We may update this policy periodically.

8. Contact Us
For privacy concerns, contact:
support@aihairstyler.com''',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _accepted,
                        onChanged: (value) =>
                            setState(() => _accepted = value ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _accepted = !_accepted),
                          child: Text(
                            'I understand and agree to the Privacy Policy',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: September 17, 2025',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Accept',
                    onPressed: () {
                      _accepted ? Navigator.of(context).pop(true) : null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
