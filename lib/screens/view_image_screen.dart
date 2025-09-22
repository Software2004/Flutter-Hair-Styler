import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hair_styler/theme/app_styles.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ViewImageScreen extends StatefulWidget {
  static const String routeName = '/view-image';

  final String imagePath; // local file path or asset
  final String title;

  const ViewImageScreen({super.key, required this.imagePath, this.title = 'Preview'});

  @override
  State<ViewImageScreen> createState() => _ViewImageScreenState();
}

class _ViewImageScreenState extends State<ViewImageScreen> {
  double _rotationTurns = 0.0; // quarter turns

  Future<void> _share() async {
    try {
      if (widget.imagePath.startsWith('/')) {
        await Share.shareXFiles([XFile(widget.imagePath)], text: widget.title);
      } else {
        // Copy asset to a temporary file so we can share the image with caption
        final ByteData data = await rootBundle.load(widget.imagePath);
        final Directory tempDir = await getTemporaryDirectory();
        final String extension = widget.imagePath.split('.').last;
        final String tempPath =
            '${tempDir.path}/shared_image_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final File file = File(tempPath);
        await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
        await Share.shareXFiles([XFile(file.path)], text: widget.title);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_backspace_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        actions: [
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: RotatedBox(
                  quarterTurns: _rotationTurns.round(),
                  child: _buildImageWidget(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _roundAction(
                  context,
                  icon: Icons.rotate_left,
                  onTap: () => setState(() => _rotationTurns = (_rotationTurns - 1) % 4),
                ),
                _roundAction(
                  context,
                  icon: Icons.rotate_right,
                  onTap: () => setState(() => _rotationTurns = (_rotationTurns + 1) % 4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (widget.imagePath.startsWith('/')) {
      return Image.file(File(widget.imagePath), fit: BoxFit.contain);
    }
    return Image.asset(widget.imagePath, fit: BoxFit.contain);
  }

  Widget _roundAction(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}


