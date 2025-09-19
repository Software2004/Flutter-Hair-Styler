import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hair_styler/screens/privacy_policy_screen.dart';
import 'package:flutter_hair_styler/screens/subscription_plan.dart';
import 'package:flutter_hair_styler/screens/terms_of_service_screen.dart';
import 'package:flutter_hair_styler/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_styles.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<void> _launchSupportEmail() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceModel = 'Unknown device';
    String osVersion = 'Unknown OS';

    try {
      final androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@aihairstyler.com',
      queryParameters: {
        'subject': 'Support Request - AI Hair Styler',
        'body': 'Device: $deviceModel\nOS Version: $osVersion',
      },
    );

    if (!await launchUrl(emailLaunchUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Guest User', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '"Future Look Revealed"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            _InfoCard(
              title: 'Credit Balance',
              trailing: Text(
                '178 Credits',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Subscription',
              trailing: Text(
                'renew on 01/10/2025',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      PrivacyPolicyScreen.routeName,
                    );
                    if (result == true) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy Policy accepted'),
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      TermsOfServiceScreen.routeName,
                    );
                    if (result == true) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terms of Service accepted'),
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _launchSupportEmail,
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: "Manage Subscription",
              icon: Icons.diamond_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageSubscriptionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Navigate to AuthScreen
              },
              icon: const Icon(Icons.login),
              label: const Text('Login / Register'),
              style: AppStyles.outlinedButton(context),
            ),
            const SizedBox(height: 32),
            Text(
              'AI Hair Styler Version V1.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _InfoCard({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          trailing,
        ],
      ),
    );
  }
}
