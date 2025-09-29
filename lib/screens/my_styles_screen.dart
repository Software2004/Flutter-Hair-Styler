import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/saved_style.dart';
import '../services/saved_styles_store.dart';
import 'view_image_screen.dart';

class MyStylesScreen extends StatefulWidget {
  const MyStylesScreen({super.key});

  @override
  State<MyStylesScreen> createState() => _MyStylesScreenState();
}

enum _SortOption { newest, oldest, name }

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

class _SortChips extends StatelessWidget {
  final _SortOption current;
  final ValueChanged<_SortOption> onChanged;

  const _SortChips({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        _chip(context, label: 'Newest', value: _SortOption.newest),
        _chip(context, label: 'Oldest', value: _SortOption.oldest),
        _chip(context, label: 'Name', value: _SortOption.name),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required _SortOption value,
  }) {
    final bool selected = value == current;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onChanged(value),
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).colorScheme.onPrimary : null,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _StyleTile extends StatelessWidget {
  final SavedStyle item;
  final VoidCallback onView;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _StyleTile({
    required this.item,
    required this.onView,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(item),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _timeAgo(item.dateSaved),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        //const SizedBox(height: 2),
                        /*Text(
                          'Saved • ${_formatDate(item.dateSaved)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),*/
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _iconButton(context, Icons.save_alt_rounded, onDownload),
                  const SizedBox(width: 6),
                  _iconButton(
                    context,
                    Icons.delete_outline_rounded,
                    onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(SavedStyle item) {
    if (item.imagePath.startsWith('/')) {
      return Image.file(
        File(item.imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _errorThumb(context),
      );
    }
    return Image.asset(
      item.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _errorThumb(context),
    );
  }

  Widget _errorThumb(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _iconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            icon,
            size: 18,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _formatDate(DateTime date) {
    final d = date;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _MyStylesScreenState extends State<MyStylesScreen>
    with AutomaticKeepAliveClientMixin {
  String _query = '';
  _SortOption _sortOption = _SortOption.newest;
  List<SavedStyle> _savedStyles = [];
  final SavedStylesStore _store = SavedStylesStore();
  StreamSubscription<List<SavedStyle>>? _subscription;

  @override
  void initState() {
    super.initState();
    _load();
    _subscription = _store.watch().listen((items) {
      if (!mounted) return;
      setState(() {
        _savedStyles = items;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await _store.load();
    if (!mounted) return;
    setState(() {
      _savedStyles = items;
    });
  }

  Future<void> _handleDownload(SavedStyle style) async {
    try {
      // On modern Android (Android 10+), writing via MediaStore does not require
      // legacy storage permission. Android 13 deprecates READ/WRITE_EXTERNAL_STORAGE
      // and requesting it will always be denied. We bypass that check and
      // directly save using `gal` which handles MediaStore.

      Uint8List? imageBytes;
      if (style.imagePath.startsWith('/')) {
        final file = File(style.imagePath);
        if (await file.exists()) {
          imageBytes = await file.readAsBytes();
        }
      } else {
        final ByteData byteData = await rootBundle.load(style.imagePath);
        imageBytes = byteData.buffer.asUint8List();
      }

      if (imageBytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image data could not be loaded.')),
        );
        return;
      }

      await Gal.putImageBytes(imageBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
    }
  }

  Future<void> _handleDelete(SavedStyle styleToDelete) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Delete Style?'),
          content: const Text('Are you sure you want to delete this style?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // await _store.deleteById(styleToDelete.id); // This line was causing issues, as _load() handles UI update
      // await _load(); // Let the stream update handle UI changes after deletion
      await _store.deleteById(styleToDelete.id); // Delete first
      _load(); // Then reload and let the stream update the UI or update directly
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${styleToDelete.name} deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine crossAxisCount based on screen width
    final int crossAxisCount = (screenWidth > 600.0) ? 4 : 2;
    // Compute tile width and a tight height that fits content (square image + info row)
    const double horizontalPadding = 16.0; // from SliverPadding
    const double crossSpacing = 16.0; // from grid delegate
    final double tileWidth =
        (screenWidth -
            (horizontalPadding * 2) -
            crossSpacing * (crossAxisCount - 1)) /
        crossAxisCount;
    // Image is square (AspectRatio 1.0) + approx 56px for text/actions row and padding
    final double tileHeight = tileWidth + 56.0;

    final List<SavedStyle> filtered = _applyFilters(_savedStyles);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final items = await _store.load();
          if (!mounted) return;
          setState(() {
            _savedStyles = items;
          });
        },
        child: CustomScrollView(
          key: const PageStorageKey('my_styles_scroll'),
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              pinned: false,
              floating: true,
              elevation: 0,
              // Using flexible space to have content that scrolls away.
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved Styles',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Browse, share or manage your favorite looks.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Height of the flexible space area.
              expandedHeight: 110,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                    const SizedBox(height: 12),
                    _SortChips(
                      current: _sortOption,
                      onChanged: (opt) => setState(() => _sortOption = opt),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 72,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text('No matching styles', style: textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: crossSpacing,
                    crossAxisSpacing: crossSpacing,
                    mainAxisExtent: tileHeight,
                  ),
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final item = filtered[index];
                    return _StyleTile(
                      item: item,
                      onView: () {
                        Navigator.pushNamed(
                          context,
                          ViewImageScreen.routeName,
                          arguments: {
                            'imagePath': item.imagePath,
                            'title': item.name,
                          },
                        );
                      },
                      onDownload: () => _handleDownload(item),
                      onDelete: () async {
                        // await _store.deleteById(item.id); // Original
                        // await _load(); // Original
                        _handleDelete(item); // Call the modified _handleDelete
                      },
                    );
                  }, childCount: filtered.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<SavedStyle> _applyFilters(List<SavedStyle> list) {
    List<SavedStyle> result = list
        .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    switch (_sortOption) {
      case _SortOption.newest:
        result.sort((a, b) => b.dateSaved.compareTo(a.dateSaved));
        break;
      case _SortOption.oldest:
        result.sort((a, b) => a.dateSaved.compareTo(b.dateSaved));
        break;
      case _SortOption.name:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }
    return result;
  }

  @override
  bool get wantKeepAlive => true;
}
