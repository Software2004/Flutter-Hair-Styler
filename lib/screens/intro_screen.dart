import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/primary_button.dart';
import '../platform/image_picker.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/intro';

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnimation;
  List<String> _images = [];
  int _current = 0;
  bool _isLoading = true;
  double _transitionDarkness = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_handlePageScroll);
    
    // Initialize rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    _rotationController.repeat();
    
    _loadAssetsAndPlay();
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients || !_pageController.position.haveDimensions) return;
    final double page = _pageController.page ?? _current.toDouble();
    final double fractional = page - page.floorToDouble();
    // Smooth dip to dark at mid-transition using sin(pi * t)
    final double dip = math.sin(math.pi * fractional).clamp(0.0, 1.0);
    final double targetDarkness = (dip * 0.35); // up to +0.35 black overlay
    if ((targetDarkness - _transitionDarkness).abs() > 0.01) {
      setState(() {
        _transitionDarkness = targetDarkness;
      });
    }
  }

  Future<void> _loadAssetsAndPlay() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final dynamic decoded = jsonDecode(manifestContent);

      // Support both legacy and new AssetManifest formats
      List<String> allAssets = [];
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('assets') && decoded['assets'] is Map<String, dynamic>) {
          // Flutter 3.16+ format: { "assets": { "path": [variants], ... }, ... }
          allAssets = (decoded['assets'] as Map<String, dynamic>).keys.cast<String>().toList();
        } else {
          // Legacy format: { "path": [variants], ... }
          allAssets = decoded.keys.cast<String>().toList();
        }
      } else if (decoded is List) {
        // Defensive: some tools may produce a flat list
        allAssets = decoded.cast<String>().toList();
      }

      // Filter for .webp files in the hairstyles directory (case-insensitive)
      final candidates = allAssets
          .where((k) => k.startsWith('assets/images/hairstyles/'))
          .where((k) => k.toLowerCase().endsWith('.webp'))
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
          duration: const Duration(milliseconds: 1500),
          curve: Curves.fastOutSlowIn,
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
    _rotationController.dispose();
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
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                  child: Stack(
                    key: ValueKey<int>(index),
                    children: [
                      // Main image
                      RotationTransition(
                        turns: _rotationAnimation,
                        child: Transform.rotate(
                          angle: math.pi, // 180-degree rotation
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(_images[index]),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.2),
                                  BlendMode.darken,
                                ),
                                onError: (error, stackTrace) {
                                  print('Error loading image ${_images[index]}: $error');
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay for depth
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
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

          // Base dark overlay + animated dip during transitions
          Container(color: Colors.black.withOpacity(0.35)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            color: Colors.black.withOpacity(_transitionDarkness),
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
            ),
          ),
        ],
      ),
    );
  }
}