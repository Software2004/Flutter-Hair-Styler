
import 'package:flutter/material.dart';
import '../models/saved_style.dart';

class FullScreenStyleScreen extends StatelessWidget {
  final SavedStyle style;

  const FullScreenStyleScreen({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(style.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(style.imagePath),
            const SizedBox(height: 16),
            Text('Details for ${style.name}'),
            Text('Saved on: ${style.dateSaved.toLocal()}'),
          ],
        ),
      ),
    );
  }
}
