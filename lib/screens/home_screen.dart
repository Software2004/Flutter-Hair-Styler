import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/style_data_provider.dart';
import '../models/models.dart';
import '../theme/app_styles.dart';
import '../widgets/credits_badge.dart';
import '../widgets/preview_list_item.dart';
import '../widgets/primary_button.dart';
import 'account_screen.dart';

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
    final pages = [
      const _HomeTab(),
      const _PlaceholderTab(title: 'AI Recommendations'),
      const _PlaceholderTab(title: 'My Styles'),
      const AccountScreen(),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith(
          (states) => Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
            height: 1.1,
          ),
        ),
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Recommend',
            tooltip: 'AI Recommendation',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'My Styles',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
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
  late final TabController _tabController;
  List<StyleCategory> _categoriesData = const [];
  bool _loading = true;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {}); // ensure rebuild on tab change
      });
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final data = await StyleDataProvider.getStyleCategories();
    if (!mounted) return;
    setState(() {
      _categoriesData = data;
      _loading = false;
    });
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
                      PrimaryButton(
                        label: 'Upload Photo',
                        icon: Icons.upload_rounded,
                        onPressed: _pickFromGallery,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
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
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: _categories.map((c) => Tab(text: c)).toList(),
                  ),
                ),
              ),
            if (_pickedImage == null)
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: _categories.map((c) {
                    if (_loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final cat = _categoriesData.firstWhere(
                      (e) => e.name == c,
                      orElse: () => const StyleCategory(name: '', styles: []),
                    );
                    final items = cat.styles;
                    if (items.isEmpty) {
                      return const Center(child: Text('No styles available'));
                    }
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: ListView.separated(
                        itemCount: items.length,
                        itemBuilder: (_, i) => PreviewListItem(
                          imageAsset: items[i].assetPath,
                          title: items[i].name,
                          onTap: () {},
                        ),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                      ),
                    );
                  }).toList(),
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
                        onPressed: () {},
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

  Widget _circleIcon(BuildContext context, IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {
          debugPrint('Pressed $icon');
        },
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    if (!mounted) return;
    
    try {
      if (!Platform.isLinux) {
        final granted = await _ensurePermission([
          Permission.photos,
          Permission.storage,
        ]);
        if (!granted || !mounted) return;
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image != null && mounted) setState(() => _pickedImage = image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing gallery: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    if (!mounted) return;
    
    try {
      if (!Platform.isLinux) {
        final granted = await _ensurePermission([Permission.camera]);
        if (!granted || !mounted) return;
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (image != null && mounted) setState(() => _pickedImage = image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool> _ensurePermission(List<Permission> permissions) async {
    // Skip permission check on Linux
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
        continue; // Already granted or limited, move to next permission
      }

      if (status.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(permissionFriendlyName);
        allActuallyGranted = false;
        continue; // No need to request, move to next permission
      }

      // If denied (but not permanently), or restricted, or another state that needs requesting:
      PermissionStatus newStatus = await p.request(); // Show system dialog

      if (newStatus.isGranted || newStatus.isLimited) {
        // User granted the permission in the dialog
        continue;
      } else if (newStatus.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(permissionFriendlyName);
        allActuallyGranted = false;
      } else {
        // User explicitly denied the permission in the dialog (newStatus.isDenied)
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      if (permanentlyDeniedPermissions.isNotEmpty) {
        // Give SnackBar a moment to be seen before opening settings
        await Future.delayed(const Duration(milliseconds: 1500));
        await openAppSettings();
      }
    }
    return allActuallyGranted;
  }
}
