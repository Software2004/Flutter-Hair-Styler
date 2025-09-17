import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> _images = const [];

  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAssetsAndPlay();
  }

  Future<void> _loadAssetsAndPlay() async {
    try {
      final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;
      final candidates = manifestMap.keys
          .where((k) => k.startsWith('assets/images/hairstyles/'))
          .toList();
      if (candidates.isNotEmpty) {
        _images = candidates;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {});
    if (_images.isNotEmpty) {
      _autoPlay();
    }
  }

  Future<void> _autoPlay() async {
    while (mounted && _images.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 4));
      _current = (_current + 1) % _images.length;
      if (!mounted) return;
      _pageController.animateToPage(
        _current,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
      );
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
          if (_images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              itemBuilder: (_, index) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  key: ValueKey(_images[index]),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          Container(color: Colors.black.withOpacity(0.45)),
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
                      style: const TextStyle(fontSize: 16, color: onDark)
                          .copyWith(color: onDark.withOpacity(0.9)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Agree & Continue', onPressed: _agreeAndContinue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


