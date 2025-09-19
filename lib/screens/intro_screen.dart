import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../widgets/primary_button.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/intro';

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final PageController _pageController;
  List<String> _images = [];
  int _current = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAssetsAndPlay();
  }

  Future<void> _loadAssetsAndPlay() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;

      // Filter for .webp files in the hairstyles directory
      final candidates = manifestMap.keys
          .where((k) => k.startsWith('assets/images/hairstyles/') && k.endsWith('.webp'))
          .toList();

      print('Found ${candidates.length} hairstyle images: $candidates'); // Debug log

      if (candidates.isNotEmpty) {
        setState(() {
          _images = candidates;
          _isLoading = false;
        });

        // Start auto-play after a short delay to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _autoPlay();
        }
      } else {
        print('No hairstyle images found in assets'); // Debug log
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading assets: $e'); // Debug log
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

      final nextIndex = (_current + 1) % _images.length;

      try {
        await _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
        );

        if (mounted) {
          setState(() {
            _current = nextIndex;
          });
        }
      } catch (e) {
        print('Error animating to page: $e');
        break;
      }
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const onDark = Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          // Background images
          if (_images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_images[index]),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                        print('Error loading image ${_images[index]}: $error');
                      },
                    ),
                  ),
                );
              },
            )
          else if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
          // Fallback background if no images are found
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

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.45)),

          // Page indicators (optional - shows which image is currently displayed)
          if (_images.length > 1)
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),

          // Content overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  const Spacer(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.shield_outlined, color: onDark, size: 36),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Transform Your Look',
                      style: TextStyle(
                        fontSize: 28,
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
            ),
          ),
        ],
      ),
    );
  }
}