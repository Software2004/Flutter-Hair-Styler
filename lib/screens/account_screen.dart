import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hair_styler/screens/login_screen.dart';
import 'package:flutter_hair_styler/screens/privacy_policy_screen.dart';
import 'package:flutter_hair_styler/screens/subscription_plan.dart';
import 'package:flutter_hair_styler/screens/terms_of_service_screen.dart';
import 'package:flutter_hair_styler/widgets/outlined_primary_button.dart';
import 'package:flutter_hair_styler/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_data.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with AutomaticKeepAliveClientMixin {
  // Controls the vertical gap between the last info card and the info tiles section

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
    super.build(context);
    final provider = context.watch<UserProvider?>();
    final credits = provider?.remainingCredits ?? 0;
    final plan = provider?.plan ?? SubscriptionPlanType.free;
    String tierLabel = switch (plan) {
      SubscriptionPlanType.free => 'Free User',
      SubscriptionPlanType.standard => 'Standard',
      SubscriptionPlanType.pro => 'Pro',
    };
    return SingleChildScrollView(
      key: const PageStorageKey('account_scroll'),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 48),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.account_circle_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
            Text('Guest User', style: Theme.of(context).textTheme.titleMedium),
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
                '$credits Credits',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Subscription',
              trailing: Text(
                tierLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 16),
              children: [
                _InfoTile(
                  title: 'Privacy Policy',
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      PrivacyPolicyScreen.routeName,
                    );
                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy Policy accepted'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _InfoTile(
                  title: 'Terms of Service',
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      TermsOfServiceScreen.routeName,
                    );
                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms of Service accepted'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _InfoTile(title: 'Support', onTap: _launchSupportEmail),
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
            const SizedBox(height: 24),
            OutlinedPrimaryButton(
              label: 'Login / Register',
              icon: Icons.login,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.routeName);
              },
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

  @override
  bool get wantKeepAlive => true;
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _InfoTile({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
