
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:image_gallery_saver/image_gallery_saver.dart'; 
import 'package:permission_handler/permission_handler.dart';

import '../models/saved_style.dart';
import '../widgets/saved_style_card.dart';

class MyStylesScreen extends StatefulWidget {
  const MyStylesScreen({super.key});

  @override
  State<MyStylesScreen> createState() => _MyStylesScreenState();
}

class _MyStylesScreenState extends State<MyStylesScreen> {
  final List<SavedStyle> _savedStyles = [
    SavedStyle(
      id: '1',
      imagePath: 'assets/images/hairstyles/afro_female.webp',
      name: 'Boho Afro Queen',
      dateSaved: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SavedStyle(
      id: '2',
      imagePath: 'assets/images/hairstyles/blunt_cut.webp',
      name: 'Chic Blunt Cut',
      dateSaved: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    SavedStyle(
      id: '3',
      imagePath: 'assets/images/hairstyles/box_braids.webp',
      name: 'Intricate Box Braids',
      dateSaved: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SavedStyle(
      id: '4',
      imagePath: 'assets/images/hairstyles/bro_flow_m.webp',
      name: 'Casual Bro Flow',
      dateSaved: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    SavedStyle(
      id: '5',
      imagePath: 'assets/images/hairstyles/asymmetrical_bob.webp',
      name: 'Modern Asymmetry',
      dateSaved: DateTime.now().subtract(const Duration(days: 3)),
    ),
     SavedStyle(
      id: '6',
      imagePath: 'assets/images/hairstyles/bald_m.webp',
      name: 'Sleek Bald Look',
      dateSaved: DateTime.now().subtract(const Duration(days: 4)),
    ),
    SavedStyle(
      id: '7',
      imagePath: 'assets/images/hairstyles/blunt_micro.webp',
      name: 'Micro Blunt Edge',
      dateSaved: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  Future<void> _handleDownload(SavedStyle style) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      try {
        final ByteData byteData = await rootBundle.load(style.imagePath);
        final Uint8List uint8List = byteData.buffer.asUint8List();
        final result = await ImageGallerySaver.saveImage(
          uint8List,
          quality: 90,
          name: "${style.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (!mounted) return;
        if (result != null && result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved to gallery!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save image: ${result?['errorMessage'] ?? 'Unknown error'}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
    }
  }

  Future<void> _handleDelete(SavedStyle styleToDelete) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Delete Style?'),
          content: const Text('Are you sure you want to delete this style?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _savedStyles.removeWhere((style) => style.id == styleToDelete.id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${styleToDelete.name} deleted.')));
    }
  }

 @override
Widget build(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  final screenWidth = MediaQuery.of(context).size.width;

  // Determine crossAxisCount based on screen width
  final int crossAxisCount = (screenWidth > 600.0) ? 4 : 2;
  // Optional: Adjust childAspectRatio for wider screens if needed
  // final double childAspectRatio = (screenWidth > 600.0) ? 0.75 : 0.70;
  const double childAspectRatio = 0.70; // Keeping it constant for now

  return Scaffold(
    appBar: AppBar( // Using a standard AppBar
      title: Text(
        'Saved Styles',
        style: textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      foregroundColor: Colors.white,
    ),
    body: Padding( // Add padding around the body content
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter( // Use SliverToBoxAdapter for non-sliver widgets
            child: Padding(
              padding: const EdgeInsets.only( bottom: 8.0), // Adjust padding as needed
              child: Text(
                'So many great looks! Tap any style to see it in full view or make changes.',
                textAlign: TextAlign.left,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _savedStyles.isEmpty
              ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 60,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Saved Styles Yet',
                        style: textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start exploring and save your favorites!',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : SliverGrid( // Keep SliverGrid directly in CustomScrollView
                  gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // Using the dynamic crossAxisCount
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: childAspectRatio, // Using the potentially dynamic childAspectRatio
                    ),
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final item = _savedStyles[index];
                        return SavedStyleCard(
                          key: ValueKey(item.id),
                          item: item,
                          onDownload: () => _handleDownload(item),
                          onDelete: () => _handleDelete(item),
                        );
                      },
                      childCount: _savedStyles.length,
                    ),
                ),
        ],
      ),
    ),
  );
}

}
