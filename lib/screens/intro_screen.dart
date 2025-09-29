import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/style_data_provider.dart';
import '../models/models.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = '/intro';

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<String> _images = [];
  int _current = 0;
  bool _isLoading = true;
  Timer? _slideshowTimer;
  bool _visible = true;
  bool _isDimmed = false;

  static const Duration _slideInterval = Duration(seconds: 4);
  static const Duration _fadeOutDuration = Duration(milliseconds: 500);
  static const Duration _fadeInDuration = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _loadAssetsAndPlay();
  }

  Future<void> _loadAssetsAndPlay() async {
    List<String> imagesToShow = [];
    try {
      List<StyleCategory> categories =
      await StyleDataProvider.getStyleCategories();

      // Define the desired order and categories to include
      const categoryOrder = ['Male', 'Female', 'Female Kids'];

      for (String categoryName in categoryOrder) {
        final category = categories.firstWhere(
              (cat) => cat.name == categoryName,
          orElse: () => StyleCategory(name: '', styles: []),
        );
        for (StyleItem item in category.styles) {
          imagesToShow.add(item.assetPath);
        }
      }

      print(
        'Found ${imagesToShow.length} hairstyle images in the specified order: $imagesToShow',
      );

      if (mounted) {
        if (imagesToShow.isNotEmpty) {
          setState(() {
            _images = imagesToShow;
            _isLoading = false;
          });
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _startSlideshowTimer();
          }
        } else {
          print('No hairstyle images found for the specified categories.');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e, s) {
      print('Error loading assets for intro screen: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'IntroScreen _loadAssetsAndPlay failed',
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startSlideshowTimer() {
    _slideshowTimer?.cancel();
    if (_images.isEmpty) return;
    _slideshowTimer = Timer.periodic(_slideInterval, (timer) async {
      if (!mounted || _images.isEmpty) return;
      // Explicit fade-out → dim → swap → fade-in sequence
      setState(() {
        _visible = false;
        _isDimmed = true;
      });

      // Wait for fade-out to complete
      await Future.delayed(_fadeOutDuration);

      final int nextIndex = (_current + 1) % _images.length;
      // Precache next 2 images ahead to smooth transitions
      final String nextPath = _images[nextIndex];
      final String secondNextPath = _images[(nextIndex + 1) % _images.length];
      try {
        await Future.wait([
          if (nextPath.isNotEmpty) precacheImage(AssetImage(nextPath), context),
          if (secondNextPath.isNotEmpty)
            precacheImage(AssetImage(secondNextPath), context),
        ]);
      } catch (e, s) {
        print('Error precaching images: $e');
        FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: 'IntroScreen precache failed',
        );
      }

      if (!mounted) return;
      setState(() {
        _current = nextIndex;
        _visible = true;
        _isDimmed = false;
      });
    });
  }

  void _stopSlideshowTimer() {
    _slideshowTimer?.cancel();
    _slideshowTimer = null;
  }

  Future<void> _agreeAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_intro', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  void dispose() {
    _stopSlideshowTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const onDark = Colors.white;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background Image with Animation
          if (_images.isNotEmpty &&
              _current < _images.length &&
              _images[_current].isNotEmpty)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: _visible ? _fadeInDuration : _fadeOutDuration,
                curve: Curves.easeInOut,
                child: Image.asset(
                  _images[_current],
                  key: ValueKey(_images[_current]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image ${_images[_current]}: $error');
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(Icons.error_outline, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            )
          else if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6B73FF), Color(0xFF9D4EDD)],
                ),
              ),
              child: const Center(
                child: Text(
                  'Could not load images.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          // Dark Overlay for better text readability + dim effect during transitions
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(_isDimmed ? 0.5 : 0.2),
                    Colors.black.withOpacity(_isDimmed ? 0.7 : 0.5),
                  ],
                ),
              ),
            ),
          ),

          // Content Layer
          Builder(
            builder: (context) {
              final padding = MediaQuery.of(context).padding;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  padding.top + 8,
                  24,
                  padding.bottom + 16,
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: onDark,
                        size: 36,
                      ),
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
                          color: onDark.withOpacity(0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Agree & Continue',
                      onPressed: _agreeAndContinue,
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