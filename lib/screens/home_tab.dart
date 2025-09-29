import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/share_text.dart';

import '../data/style_data_provider.dart';
import '../models/models.dart';
import '../models/saved_style.dart';
import '../models/user_data.dart';
import '../platform/image_picker.dart';
import '../providers/user_provider.dart';
import '../services/gemini_service.dart';
import '../services/saved_styles_store.dart';
import '../services/watermark_util.dart';
import '../widgets/home_screen_header.dart';
import '../widgets/outlined_primary_button.dart';
import '../widgets/picked_image_layout.dart';
import '../widgets/primary_button.dart';
import 'view_image_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final List<String> _categories = const [
    'Male',
    'Female',
    'Male Kids',
    'Female Kids',
  ];

  final List<IconData> _categoryIcons = const [
    Icons.man,
    Icons.woman_rounded,
    Icons.boy,
    Icons.girl,
  ];

  late final TabController _tabController;
  List<StyleCategory> _categoriesData = const [];
  bool _loading = true;
  XFile? _pickedImage;
  bool _isPickingImage = false;
  bool _isGenerating = false;
  Uint8List? _generatedBytes;
  double _rotationTurns = 0;
  bool _showOriginal = false;
  String? _generatedStyleName;
  final SavedStylesStore _store = SavedStylesStore();
  bool _isSaving = false;
  String? _lastSavedSignature;

  late final GeminiService _gemini;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _loadAssets();
    String apiKey = dotenv.env["GEMINI_API_KEY"] ?? "";
    _gemini = GeminiService(apiKey);
  }

  Future<void> _loadAssets() async {
    try {
      final data = await StyleDataProvider.getStyleCategories();
      if (!mounted) return;

      debugPrint('Loaded ${data.length} categories');
      for (var category in data) {
        debugPrint(
          'Category: ${category.name} has ${category.styles.length} styles',
        );
        if (category.styles.isNotEmpty) {
          debugPrint(
            'First style: ${category.styles.first.name} - ${category.styles.first.assetPath}',
          );
        }
      }

      setState(() {
        _categoriesData = data;
        _loading = false;
      });

      // Additional debug to verify data structure
      debugPrint(
        'Final categories data: ${_categoriesData.map((c) => '${c.name}: ${c.styles.length} styles').toList()}',
      );
    } catch (e) {
      debugPrint('Error loading assets: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading style data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (_pickedImage != null) {
          setState(() => _pickedImage = null);
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: CustomScrollView(
          key: const PageStorageKey('home_tab_scroll'),
          slivers: [
            const SliverToBoxAdapter(child: HomeScreenHeader()),
            if (_pickedImage == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Try a new look today!',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Upload your photo or take a new one to discover amazing hairstyles.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _isPickingImage
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              label: 'Upload Photo',
                              icon: Icons.file_upload_outlined,
                              onPressed: _pickFromGallery,
                            ),
                      const SizedBox(height: 16),
                      _isPickingImage
                          ? Container()
                          : OutlinedPrimaryButton(
                              onPressed: _pickFromCamera,
                              icon: Icons.photo_camera_outlined,
                              label: 'Open Camera',
                            ),
                      const SizedBox(height: 48),
                      Center(
                        child: Text(
                          'AI Style Previews',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "AI-generated previews showing how you'd look",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            if (_pickedImage == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x22AAAAAA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        indicator: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Theme.of(context).colorScheme.onSurface,
                        unselectedLabelColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: List.generate(_categories.length, (index) {
                          return Tab(
                            child: Row(
                              children: [
                                Icon(_categoryIcons[index], size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _categories[index],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            if (_pickedImage == null)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: _currentTabGridHeight(context),
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return IndexedStack(
                        index: _tabController.index,
                        children: _categories.map((categoryName) {
                          if (_loading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          StyleCategory? matchingCategory;
                          for (var cat in _categoriesData) {
                            if (cat.name.toLowerCase() ==
                                categoryName.toLowerCase()) {
                              matchingCategory = cat;
                              break;
                            }
                          }

                          if (matchingCategory == null ||
                              matchingCategory.styles.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.content_cut,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No styles available for $categoryName',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please check if the assets are properly loaded',
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(color: Colors.grey[500]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.68,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: matchingCategory!.styles.length,
                              itemBuilder: (context, index) {
                                final item = matchingCategory!.styles[index];
                                return _buildStyleCard(item);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            if (_pickedImage != null)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Stack(
                    children: [
                      PickedImageLayout(
                        imagePath: _pickedImage!.path,
                        onBack: () => setState(() => _pickedImage = null),
                        onChangeStyle: _showStyleChooserBottomSheet,
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
                              arguments: {
                                'imagePath': _pickedImage!.path,
                                'title': title,
                              },
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
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateGridHeight(BuildContext context, int itemCount) {
    // Grid: 2 columns, childAspectRatio 0.8, spacing 16, padding 16
    const int crossAxisCount = 2;
    const double crossAxisSpacing = 16;
    const double mainAxisSpacing = 16;
    const double childAspectRatio = 0.68; // width / height (matches grid above)

    final double horizontalPadding = 16 * 2; // from Padding around Grid
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth =
        screenWidth - horizontalPadding - crossAxisSpacing;
    final double itemWidth = (availableWidth) / crossAxisCount;
    final double itemHeight = itemWidth / childAspectRatio;

    final int rows = (itemCount / crossAxisCount).ceil();
    final double totalHeight =
        (rows * itemHeight) + ((rows - 1) * mainAxisSpacing);
    return totalHeight;
  }

  double _currentTabGridHeight(BuildContext context) {
    if (_loading) {
      // Reserve some height to show progress indicator nicely
      return MediaQuery.of(context).size.height * 0.3;
    }

    final String currentCategory = _categories[_tabController.index];
    StyleCategory? matchingCategory;
    for (var cat in _categoriesData) {
      if (cat.name.toLowerCase() == currentCategory.toLowerCase()) {
        matchingCategory = cat;
        break;
      }
    }

    final int itemCount = matchingCategory?.styles.length ?? 0;

    // If empty, allocate minimal space so placeholder can be centered
    if (itemCount == 0) {
      return MediaQuery.of(context).size.height * 0.25;
    }

    // Add extra space for top/bottom paddings inside the sliver section
    final double grid = _calculateGridHeight(context, itemCount);
    return grid + 32; // 16 top + 16 bottom padding
  }

  Widget _buildStyleCard(StyleItem item, {VoidCallback? onTap}) {
    return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap:
            onTap ??
            () {
              Navigator.pushNamed(
                context,
                ViewImageScreen.routeName,
                arguments: {'imagePath': item.assetPath, 'title': item.name},
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter, // Added this line
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    if (!mounted || _isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await PlatformImagePicker.pickImageFromGallery();

      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
        if (image != null) {
          _pickedImage = image;
          debugPrint('Image picked from gallery: ${image.path}');
          _generatedBytes = null;
          _showStyleChooserBottomSheet();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image loaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          debugPrint('No image selected from gallery');
        }
      });
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing gallery: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    if (!mounted || _isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await PlatformImagePicker.pickImageFromCamera();

      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
        if (image != null) {
          _pickedImage = image;
          debugPrint('Image taken from camera: ${image.path}');
          _generatedBytes = null;
          _showStyleChooserBottomSheet();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo taken successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          debugPrint('No image taken from camera');
        }
      });
    } catch (e) {
      debugPrint('Error taking photo with camera: $e');
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing camera: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStyleChooserBottomSheet() {
    if (_pickedImage == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        StyleItem? selected;
        return DefaultTabController(
          length: _categories.length,
          initialIndex: _tabController.index,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (context, setLocalState) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Choose your style',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x22AAAAAA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              indicator: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              unselectedLabelColor: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                              splashFactory: NoSplash.splashFactory,
                              overlayColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                              dividerColor: Colors.transparent,
                              tabs: List.generate(_categories.length, (index) {
                                return Tab(
                                  child: Row(
                                    children: [
                                      Icon(_categoryIcons[index], size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        _categories[index],
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: _categories.map((categoryName) {
                            StyleCategory? matchingCategory;
                            for (var cat in _categoriesData) {
                              if (cat.name.toLowerCase() ==
                                  categoryName.toLowerCase()) {
                                matchingCategory = cat;
                                break;
                              }
                            }
                            if (matchingCategory == null ||
                                matchingCategory.styles.isEmpty) {
                              return Center(
                                child: Text(
                                  'No styles available for $categoryName',
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: GridView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.7,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: matchingCategory.styles.length,
                                itemBuilder: (context, index) {
                                  final item = matchingCategory!.styles[index];
                                  return _buildStyleCard(
                                    item,
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      if (item.prompt.isNotEmpty) {
                                        await _startGenerationWithPrompt(
                                          item.prompt,
                                          item.name,
                                        );
                                      } else {
                                        await _startGeneration();
                                      }
                                    },
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: PrimaryButton(
                          label: 'AI Recommended',
                          icon: Icons.auto_awesome_outlined,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if (selected != null &&
                                selected.prompt.isNotEmpty) {
                              await _startGenerationWithPrompt(
                                selected.prompt,
                                selected.name,
                              );
                            } else {
                              await _startGeneration();
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _startGenerationWithPrompt(
    String prompt,
    String styleName,
  ) async {
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
      final result = await _gemini.editWithPrompt(
        imageFile: file,
        prompt: prompt,
      );
      if (!mounted) return;
      setState(() {
        _generatedBytes = result.bytes;
        _generatedStyleName = styleName;
        _lastSavedSignature = null;
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
        _lastSavedSignature = null;
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
      final shareMessage = buildShareText(styleName: _generatedStyleName);
      await Share.shareXFiles([XFile(file.path)], text: shareMessage);
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
      if (_isSaving) {
        return;
      }
      final plan = context.read<UserProvider>().plan;
      Uint8List toWrite = _generatedBytes!;
      if (plan == SubscriptionPlanType.free) {
        toWrite = await WatermarkUtil.applyWatermark(imageBytes: toWrite);
      }

      final String signature = _signatureForBytes(toWrite);
      if (_lastSavedSignature == signature) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This result is already saved')),
        );
        return;
      }

      _isSaving = true;
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
      _lastSavedSignature = signature;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved to My Styles')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
    finally {
      _isSaving = false;
    }
  }

  void _compareOriginal() {}

  @override
  bool get wantKeepAlive => true;
}

// Compute a lightweight signature to detect duplicate saves for the same bytes
String _signatureForBytes(Uint8List bytes) {
  final int len = bytes.length;
  if (len == 0) return '0:';
  final int take = len < 128 ? len : 64;
  final String head = base64Encode(bytes.sublist(0, take));
  final String tail = base64Encode(bytes.sublist(len - take, len));
  return '$len:$head:$tail';
}
