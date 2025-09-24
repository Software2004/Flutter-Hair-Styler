import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../widgets/primary_button.dart';
import 'home_screen.dart';
import '../data/style_data_provider.dart';
import '../models/models.dart';

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
  bool _blackOverlayVisible = false;

  @override
  void initState() {
    super.initState();
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
    List<String> imagesToShow = [];
    try {
      List<StyleCategory> categories = await StyleDataProvider.getStyleCategories();
      
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

      print('Found ${imagesToShow.length} hairstyle images in the specified order: $imagesToShow');

      if (mounted) {
        if (imagesToShow.isNotEmpty) {
          setState(() {
            _images = imagesToShow;
            _isLoading = false;
          });
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _autoPlay();
          }
        } else {
          print('No hairstyle images found for the specified categories.');
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading assets for intro screen: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _autoPlay() async {
    if (_images.isEmpty) return;

    while (mounted && _images.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return;

      final int nextIndex = (_current + 1) % _images.length;
      final String nextPath = _images[nextIndex];
      try {
        if (nextPath.isNotEmpty) {
          await precacheImage(AssetImage(nextPath), context);
        }
      } catch (e) {
        print("Error precaching image $nextPath: $e");
      }

      setState(() {
        _blackOverlayVisible = true;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      setState(() {
        _current = nextIndex;
      });

      await WidgetsBinding.instance.endOfFrame;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const onDark = Colors.white;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          if (_images.isNotEmpty && _current < _images.length && _images[_current].isNotEmpty)
            Positioned.fill(
              child: Transform.rotate(
                angle: math.pi, 
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
              child: const Center(
                child: Text(
                  'Could not load images.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          Container(color: Colors.black.withOpacity(0.35)),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            opacity: _blackOverlayVisible ? 1.0 : 0.0,
            child: Container(color: Colors.black),
          ),

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
