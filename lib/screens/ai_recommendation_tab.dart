import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';

import '../services/image_picker_service.dart';
import '../widgets/home_screen_header.dart';
import '../widgets/outlined_primary_button.dart';
import '../widgets/picked_image_layout.dart';
import '../widgets/primary_button.dart';
import 'privacy_policy_screen.dart';

class AIRecommendationTab extends StatefulWidget {
  const AIRecommendationTab({super.key});

  @override
  State<AIRecommendationTab> createState() => _AIRecommendationTabState();
}

class _AIRecommendationTabState extends State<AIRecommendationTab> {
  XFile? _pickedImage;
  bool _isPicking = false;

  Future<void> _pickFromGallery() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final image = await ImagePickerService.pickFromGallery();
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _pickedImage = image;
      });
      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image loaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPicking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFromCamera() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final image = await ImagePickerService.pickFromCamera();
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _pickedImage = image;
      });
      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo taken successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPicking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pickedImage != null) {
      return PickedImageLayout(
        imagePath: _pickedImage!.path,
        onBack: () => setState(() => _pickedImage = null),
        onChangeStyle: () {},
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeScreenHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_outlined, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        'Try Best AI Recommended Look',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For best results, use a clear, front-facing photo with your hair pulled back.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _InstructionCard(),
                  const SizedBox(height: 24),
                  _isPicking
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedPrimaryButton(
                                label: 'Camera',
                                icon: Icons.photo_camera_outlined,
                                onPressed: _pickFromCamera,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                                label: 'Photo',
                                icon: Icons.photo_library_outlined,
                                onPressed: _pickFromGallery,
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
            child: _PrivacyNote(),
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32,horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid, // Flutter lacks dotted; keep subtle border
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 54,color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(height: 12),
          Text(
            'Clear frontal face shot',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'No glasses or hats',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7)
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),fontSize: 12
        );
    return Text.rich(
      TextSpan(
        text:
            'Your photo is used solely for generating hairstyle recommendations and is not stored or used for any other purpose. ',
        style: baseStyle,
        children: [
          TextSpan(
            text: 'Privacy Policy',
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.pushNamed(
                    context,
                    PrivacyPolicyScreen.routeName,
                  ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
