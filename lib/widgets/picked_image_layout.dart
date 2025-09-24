import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';

class PickedImageLayout extends StatelessWidget {
  final String imagePath;
  final VoidCallback onBack;
  final VoidCallback? onCompare;
  final VoidCallback? onComparePressStart;
  final VoidCallback? onComparePressEnd;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onRotateLeft;
  final VoidCallback? onRotateRight;
  final VoidCallback onChangeStyle;
  final Uint8List? generatedBytes;
  final int rotationQuarterTurns;
  final VoidCallback? onTap;
  final bool showOriginalOverride;

  const PickedImageLayout({
    super.key,
    required this.imagePath,
    required this.onBack,
    required this.onChangeStyle,
    this.onCompare,
    this.onComparePressStart,
    this.onComparePressEnd,
    this.onShare,
    this.onSave,
    this.onRotateLeft,
    this.onRotateRight,
    this.generatedBytes,
    this.rotationQuarterTurns = 0,
    this.onTap,
    this.showOriginalOverride = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            child: RotatedBox(
              quarterTurns: rotationQuarterTurns % 4,
              child: (generatedBytes != null && !showOriginalOverride)
                  ? Image.memory(
                      generatedBytes!,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
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
          ),
        ),
        Positioned(
          top: 20,
          left: 16,
          child: _circleIcon(
            context,
            Icons.arrow_back_rounded,
            onPressed: onBack,
          ),
        ),
        Positioned(
          top: 20,
          right: 16,
          child: Column(
            children: [
              _pressableCircleIcon(
                context,
                Icons.compare_rounded,
                onPressed: onCompare,
                onPressStart: onComparePressStart,
                onPressEnd: onComparePressEnd,
              ),
              const SizedBox(height: 14),
              _circleIcon(context, Icons.share_rounded, onPressed: onShare),
              const SizedBox(height: 14),
              _circleIcon(context, Icons.save, onPressed: onSave),
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
              _circleIcon(context, Icons.rotate_left_rounded, onPressed: onRotateLeft),
              _circleIcon(context, Icons.rotate_right_rounded, onPressed: onRotateRight),
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
            onPressed: onChangeStyle,
          ),
        ),
      ],
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
        onPressed: onPressed,
      ),
    );
  }

  Widget _pressableCircleIcon(
    BuildContext context,
    IconData icon, {
    VoidCallback? onPressed,
    VoidCallback? onPressStart,
    VoidCallback? onPressEnd,
  }) {
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) => onPressStart?.call(),
      onTapUp: (_) => onPressEnd?.call(),
      onTapCancel: () => onPressEnd?.call(),
      child: _circleIcon(context, icon, onPressed: onPressed),
    );
  }
}


