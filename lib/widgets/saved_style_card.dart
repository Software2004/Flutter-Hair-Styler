
import 'package:flutter/material.dart';
import '../models/saved_style.dart';
import '../screens/full_screen_style_screen.dart'; // For navigation

class SavedStyleCard extends StatelessWidget {
  final SavedStyle item;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const SavedStyleCard({
    super.key,
    required this.item,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenStyleScreen(style: item),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback for image load errors
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Text Overlay at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: colorScheme.onPrimary, // Assuming text is on a dark gradient
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Action Buttons at the top-right
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Download Button
                  Container(
                     decoration: BoxDecoration(
                       color: colorScheme.secondary.withOpacity(0.7),
                       shape: BoxShape.circle,
                     ),
                    child: IconButton(
                      icon: Icon(Icons.download_outlined, color: colorScheme.onSecondary),
                      onPressed: onDownload,
                      tooltip: 'Download',
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Delete Button
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, color: colorScheme.onError),
                      onPressed: onDelete,
                      tooltip: 'Delete',
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
}
