import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart'; // Not used in this file directly

import '../widgets/primary_button.dart';
// import '../platform/image_picker.dart'; // Not used in this file directly
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/intro';

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  // Removed PageController and slide-based navigation
  List<String> _images = [];
  int _current = 0;
  bool _isLoading = true;
  bool _blackOverlayVisible = false; // For 300ms fade-to-black between images

  @override
  void initState() {
    super.initState();
    // Enable edge-to-edge and make system bars transparent on this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _loadAssetsAndPlay();
  }

  Future<void> _loadAssetsAndPlay() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final dynamic decoded = jsonDecode(manifestContent);

      List<String> allAssets = [];
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('assets') && decoded['assets'] is Map<String, dynamic>) {
          allAssets = (decoded['assets'] as Map<String, dynamic>).keys.cast<String>().toList();
        } else {
          allAssets = decoded.keys.cast<String>().toList();
        }
      } else if (decoded is List) {
        allAssets = decoded.cast<String>().toList();
      }

      final candidates = allAssets
          .where((k) => k.startsWith('assets/images/hairstyles/'))
          .where((k) => k.toLowerCase().endsWith('.webp'))
          .toList();

      print('Found ${candidates.length} hairstyle images: $candidates');

      if (candidates.isNotEmpty) {
        setState(() {
          _images = candidates;
          _isLoading = false;
        });

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _autoPlay();
        }
      } else {
        print('No hairstyle images found in assets');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading assets: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _autoPlay() async {
    if (_images.isEmpty) return;

    while (mounted && _images.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;

      // Smoothness: pre-cache the next image before transitioning
      final int nextIndex = (_current + 1) % _images.length;
      final String nextPath = _images[nextIndex];
      try {
        await precacheImage(AssetImage(nextPath), context);
      } catch (_) {}

      // Fade to black over 300ms
      setState(() {
        _blackOverlayVisible = true;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Swap image instantly while black overlay is visible
      setState(() {
        _current = nextIndex;
      });

      // Wait until the frame with the new image is rendered to avoid visible jerk
      await WidgetsBinding.instance.endOfFrame;

      // Fade back from black over 300ms
      if (!mounted) return;
      setState(() {
        _blackOverlayVisible = false;
      });
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _agreeAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_intro', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  void dispose() {
    // Optionally restore UI mode if needed (kept minimal to affect only this screen)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const onDark = Colors.white;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background image (single image at a time)
          if (_images.isNotEmpty)
            Positioned.fill(
              child: Transform.rotate(
                angle: math.pi, // rotate slideshow by 180 degrees
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_images[_current]),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                      onError: (error, stackTrace) {
                        print('Error loading image ${_images[_current]}: $error');
                      },
                    ),
                  ),
                ),
              ),
            )
          else if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6B73FF),
                    Color(0xFF9D4EDD),
                  ],
                ),
              ),
            ),

          Container(color: Colors.black.withOpacity(0.35)),
          // Fade-to-black overlay (300ms)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            opacity: _blackOverlayVisible ? 1.0 : 0.0,
            child: Container(color: Colors.black),
          ),

          // Edge-to-edge content (drawn beneath transparent system bars)
          Builder(
            builder: (context) {
              final padding = MediaQuery.of(context).padding;
              return Padding(
                padding: EdgeInsets.fromLTRB(24, padding.top + 8, 24, padding.bottom + 16),
                child: Column(
                  children: [
                    const Spacer(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.lightbulb_outline, color: onDark, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Transform Your Look',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: onDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your photos are processed securely by AI and never stored.',
                        style: TextStyle(
                            fontSize: 16,
                            color: onDark.withOpacity(0.9)
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                        label: 'Agree & Continue',
                        onPressed: _agreeAndContinue
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
