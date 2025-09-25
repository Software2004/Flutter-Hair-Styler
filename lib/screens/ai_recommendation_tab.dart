import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/saved_style.dart';
import '../models/user_data.dart';
import '../providers/user_provider.dart';
import '../services/gemini_service.dart';
import '../services/image_picker_service.dart';
import '../services/saved_styles_store.dart';
import '../services/watermark_util.dart';
import '../widgets/home_screen_header.dart';
import '../widgets/outlined_primary_button.dart';
import '../widgets/picked_image_layout.dart';
import '../widgets/primary_button.dart';
import 'privacy_policy_screen.dart';
import 'view_image_screen.dart';

class AIRecommendationTab extends StatefulWidget {
  const AIRecommendationTab({super.key});

  @override
  State<AIRecommendationTab> createState() => _AIRecommendationTabState();
}

class _AIRecommendationTabState extends State<AIRecommendationTab>
    with AutomaticKeepAliveClientMixin {
  XFile? _pickedImage;
  bool _isPicking = false;
  bool _isGenerating = false;
  Uint8List? _generatedBytes;
  double _rotationTurns = 0;
  bool _showOriginal = false;
  String? _generatedStyleName;
  final SavedStylesStore _store = SavedStylesStore();

  late final GeminiService _gemini;

  @override
  void initState() {
    super.initState();
    String apiKey = dotenv.env["GEMINI_API_KEY"] ?? "";
    print("API KEY ->>" + apiKey);
    _gemini = GeminiService(apiKey);
  }

  Future<void> _startGeneration() async {
    if (_pickedImage == null || _isGenerating) return;
    final userProvider = context.read<UserProvider>();
    final hasCredit = await userProvider.ensureCreditForGeneration();
    if (!hasCredit) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Out of credits. Upgrade or buy more.')),
      );
      return;
    }
    if (_gemini.apiKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gemini API key not set')));
      return;
    }
    setState(() {
      _isGenerating = true;
    });
    try {
      final file = File(_pickedImage!.path);
      final result = await _gemini.generateAiRecommendation(imageFile: file);
      if (!mounted) return;
      setState(() {
        _generatedBytes = result.bytes;
        _generatedStyleName = result.styleName;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Generation failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _openGeneratedInViewer() async {
    if (_generatedBytes == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/ai_result_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(_generatedBytes!, flush: true);
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        ViewImageScreen.routeName,
        arguments: {'imagePath': file.path, 'title': 'AI Result'},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Open failed: $e')));
    }
  }

  Future<void> _shareCurrent() async {
    try {
      final plan = context.read<UserProvider>().plan;
      Uint8List bytes =
          _generatedBytes ?? await File(_pickedImage!.path).readAsBytes();
      if (plan == SubscriptionPlanType.free && _generatedBytes != null) {
        bytes = await WatermarkUtil.applyWatermark(imageBytes: bytes);
      }
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: 'AI Hair Styler');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }

  Future<void> _saveCurrent() async {
    try {
      if (_generatedBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generate an image first')),
        );
        return;
      }
      final plan = context.read<UserProvider>().plan;
      Uint8List toWrite = _generatedBytes!;
      if (plan == SubscriptionPlanType.free) {
        toWrite = await WatermarkUtil.applyWatermark(imageBytes: toWrite);
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/ai_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(toWrite, flush: true);

      final saved = SavedStyle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: file.path,
        name: _generatedStyleName ?? 'AI Recommended',
        dateSaved: DateTime.now(),
      );
      await _store.append(saved);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved to My Styles')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  void _compareOriginal() {}

  Future<void> _pickFromGallery() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final image = await ImagePickerService.pickFromGallery();
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _pickedImage = image;
        _generatedBytes = null;
      });
      if (image != null) {
        _startGeneration();
      }
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
        _generatedBytes = null;
      });
      if (image != null) {
        _startGeneration();
      }
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
    super.build(context);
    if (_pickedImage != null) {
      final imagePath = _pickedImage!.path;
      return SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const HomeScreenHeader(),
            Expanded(
              child: Stack(
                children: [
                  PickedImageLayout(
                    imagePath: imagePath,
                    onBack: () => setState(() => _pickedImage = null),
                    onChangeStyle: _startGeneration,
                    onRotateLeft: () => setState(
                      () => _rotationTurns = (_rotationTurns - 1) % 4,
                    ),
                    onRotateRight: () => setState(
                      () => _rotationTurns = (_rotationTurns + 1) % 4,
                    ),
                    onShare: _shareCurrent,
                    onSave: _saveCurrent,
                    onCompare: _compareOriginal,
                    generatedBytes: _generatedBytes,
                    rotationQuarterTurns: _rotationTurns.round(),
                    onTap: () {
                      final title = _generatedBytes != null
                          ? 'AI Result'
                          : 'Preview';
                      if (_generatedBytes != null) {
                        _openGeneratedInViewer();
                      } else {
                        Navigator.pushNamed(
                          context,
                          ViewImageScreen.routeName,
                          arguments: {'imagePath': imagePath, 'title': title},
                        );
                      }
                    },
                    showOriginalOverride: _showOriginal,
                    onComparePressStart: () =>
                        setState(() => _showOriginal = true),
                    onComparePressEnd: () =>
                        setState(() => _showOriginal = false),
                  ),
                  if (_isGenerating)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeScreenHeader(),
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey('ai_tab_scroll'),
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

  @override
  bool get wantKeepAlive => true;
}

class _InstructionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
          Icon(
            Icons.account_circle,
            size: 54,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      fontSize: 12,
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
              ..onTap = () =>
                  Navigator.pushNamed(context, PrivacyPolicyScreen.routeName),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
