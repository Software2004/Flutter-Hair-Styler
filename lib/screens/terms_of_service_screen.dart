import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';

class TermsOfServiceScreen extends StatefulWidget {
  static const String routeName = '/terms-of-service';

  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Terms of Service')),
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
                      'Terms of Service',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '''Welcome to AI Hair Styler! By using our app, you agree to these terms.

1. Acceptance of Terms
By accessing or using AI Hair Styler, you agree to be bound by these Terms of Service.

2. Service Description
AI Hair Styler provides virtual hairstyle preview services using artificial intelligence.

3. User Accounts
- You must maintain accurate account information
- You are responsible for account security
- One account per user

4. User Content
- You retain rights to your photos
- You grant us license to process your photos
- No inappropriate content allowed

5. Subscription and Payments
- Subscription fees are billed in advance
- No refunds for partial months
- Prices may change with notice

6. Credits System
- Credits are non-refundable
- Credits expire after 12 months
- Credits are non-transferable

7. Prohibited Activities
You may not:
- Violate any laws
- Impersonate others
- Abuse the service

8. Termination
We may terminate service for violations.

9. Disclaimer of Warranties
Service provided "as is" without warranties.

10. Limitation of Liability
Our liability is limited to subscription fees paid.

11. Changes to Terms
We may modify terms with notice.

12. Contact
Questions about terms:
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
                            'I understand and agree to the Terms of Service',
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
