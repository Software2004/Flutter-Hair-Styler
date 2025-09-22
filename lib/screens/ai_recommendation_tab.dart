import 'dart:io';

import 'package:flutter/material.dart';
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
          const SnackBar(content: Text('Image loaded successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPicking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing gallery: $e'), backgroundColor: Colors.red),
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
          const SnackBar(content: Text('Photo taken successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPicking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: $e'), backgroundColor: Colors.red),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeScreenHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 22),
                    const SizedBox(width: 8),
                    Text('Try Best AI Recommended Look', style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'For best results, use a clear, front-facing photo with your hair pulled back.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _InstructionCard(),
                const SizedBox(height: 20),
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
                const SizedBox(height: 16),
                _PrivacyNote(),
              ],
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid, // Flutter lacks dotted; keep subtle border
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clear frontal face shot',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'No glasses or hats',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Your photo is used solely for generating hairstyle recommendations and is not stored or used for any other purpose.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, PrivacyPolicyScreen.routeName),
          child: const Text(
            'Privacy Policy',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}


