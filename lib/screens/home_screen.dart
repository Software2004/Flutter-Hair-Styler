import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/style_data_provider.dart';
import '../models/models.dart';
import '../theme/app_styles.dart';
import '../widgets/credits_badge.dart';
import '../widgets/primary_button.dart';
import 'account_screen.dart';
import 'my_styles_screen.dart'; // Added import for MyStylesScreen

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Updated pages list to include MyStylesScreen
    final pages = [
      const _HomeTab(),
      const _PlaceholderTab(title: 'AI Recommendations'),
      // This could be next to implement
      const MyStylesScreen(),
      // Replaced _PlaceholderTab with MyStylesScreen
      const AccountScreen(),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          showUnselectedLabels: true,
          selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.labelSmall
              ?.copyWith(fontWeight: FontWeight.w400, height: 1.5),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'AI Recommendations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'My Styles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;

  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  final List<String> _categories = const [
    'Male',
    'Female',
    'Male Kids',
    'Female Kids',
  ];

  final List<IconData> _categoryIcons = const [
    Icons.male,
    Icons.female,
    Icons.boy,
    Icons.girl,
  ];

  late final TabController _tabController;
  List<StyleCategory> _categoriesData = const [];
  bool _loading = true;
  XFile? _pickedImage;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _loadAssets();
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
      debugPrint('Final categories data: ${_categoriesData.map((c) => '${c.name}: ${c.styles.length} styles').toList()}');
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
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.face_6_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI Hair Styler',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    const CreditsBadge(credits: 179),
                  ],
                ),
              ),
            ),
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
                          : OutlinedButton.icon(
                              onPressed: _pickFromCamera,
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('Open Camera'),
                              style: AppStyles.outlinedButton(context),
                            ),
                      const SizedBox(height: 48),
                      Center(
                        child: Text(
                          'Your Style Previews',
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
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3.0,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: List.generate(_categories.length, (index) {
                      return Tab(
                        child: Row(
                          children: [
                            Icon(_categoryIcons[index], size: 20),
                            const SizedBox(width: 8),
                            Text(_categories[index]),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            if (_pickedImage == null)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: TabBarView(
                    controller: _tabController,
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
                      
                      // Debug print to help identify the issue
                      debugPrint('Looking for category: $categoryName');
                      debugPrint('Available categories: ${_categoriesData.map((c) => c.name).toList()}');
                      debugPrint('Found matching category: ${matchingCategory?.name}');

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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: matchingCategory.styles.length,
                          itemBuilder: (context, index) {
                            final item = matchingCategory!.styles[index];
                            return _buildStyleCard(item);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (_pickedImage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        File(_pickedImage!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading image',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 16,
                      child: _circleIcon(
                        context,
                        Icons.arrow_back_rounded,
                        onPressed: () {
                          setState(() {
                            _pickedImage = null;
                          });
                        },
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 16,
                      child: Column(
                        children: [
                          _circleIcon(context, Icons.compare_rounded),
                          const SizedBox(height: 14),
                          _circleIcon(context, Icons.share_rounded),
                          const SizedBox(height: 14),
                          _circleIcon(context, Icons.save_alt_rounded),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 110,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _circleIcon(context, Icons.rotate_left_rounded),
                          _circleIcon(context, Icons.rotate_right_rounded),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: PrimaryButton(
                        label: 'Change Hairstyle',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: () {
                          debugPrint('Change hairstyle pressed');
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard(StyleItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          debugPrint('Selected style: ${item.name}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
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

  Widget _circleIcon(
    BuildContext context,
    IconData icon, {
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed:
            onPressed ??
            () {
              debugPrint('Pressed $icon');
            },
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    if (!mounted || _isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      if (!Platform.isLinux) {
        final granted = await _ensurePermission([
          Permission.photos,
          Permission.storage,
        ]);

        if (!granted) {
          setState(() {
            _isPickingImage = false;
          });
          return;
        }
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
        if (image != null) {
          _pickedImage = image;
          debugPrint('Image picked from gallery: ${image.path}');
          
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
      if (!Platform.isLinux) {
        final granted = await _ensurePermission([Permission.camera]);

        if (!granted) {
          setState(() {
            _isPickingImage = false;
          });
          return;
        }
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (!mounted) return;

      setState(() {
        _isPickingImage = false;
        if (image != null) {
          _pickedImage = image;
          debugPrint('Image taken from camera: ${image.path}');
          
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

  Future<bool> _ensurePermission(List<Permission> permissions) async {
    if (Platform.isLinux) return true;

    List<String> permanentlyDeniedPermissions = [];
    List<String> deniedPermissions = [];
    bool allActuallyGranted = true;

    for (final p in permissions) {
      PermissionStatus status = await p.status;
      String permissionName = p.toString().split('.').last;
      String permissionFriendlyName =
          permissionName[0].toUpperCase() + permissionName.substring(1);

      if (status.isGranted || status.isLimited) {
        continue;
      }

      if (status.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(permissionFriendlyName);
        allActuallyGranted = false;
        continue;
      }

      PermissionStatus newStatus = await p.request();

      if (newStatus.isGranted || newStatus.isLimited) {
        continue;
      } else if (newStatus.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(permissionFriendlyName);
        allActuallyGranted = false;
      } else {
        deniedPermissions.add(permissionFriendlyName);
        allActuallyGranted = false;
      }
    }

    if (!allActuallyGranted && mounted) {
      String message = '';
      if (permanentlyDeniedPermissions.isNotEmpty) {
        message =
            '${permanentlyDeniedPermissions.join(', ')} permission(s) are permanently denied. Please enable in app settings.';
      } else if (deniedPermissions.isNotEmpty) {
        message = '${deniedPermissions.join(', ')} permission(s) were denied.';
      }

      if (message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (permanentlyDeniedPermissions.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 1500));
        await openAppSettings();
      }
    }

    return allActuallyGranted;
  }
}
