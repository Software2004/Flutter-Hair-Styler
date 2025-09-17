import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/models.dart';

class StyleDataProvider {
  static const String basePath = 'assets/images/hairstyles/';

  // Optional curated mapping inspired by your reference lists. Extend freely.
  // Keys should be the image file name without extension.
  static const Map<String, String> _displayName = {
    'undercut_m': 'Undercut',
    'popadour_m': 'Pompadour',
    'fade_m': 'Fade (Skin Fade)',
    'quiff_m': 'Quiff',
    'side_part_m': 'Side Part',
    'crew_cut_m': 'Crew Cut',
    'french_crop_m': 'French Crop',
    'slicked_back_m': 'Slicked Back',
    'man_bun_m': 'Man Bun',
    'afro_m': 'Afro',
    'buzz_off_m': 'Buzz Cut',
    'dread_locks_m': 'Dreadlocks',
    'comb_over': 'Comb Over',
    'mullet_m': 'Mullet',
    'bro_flow_m': 'Bro Flow',
    'taper_fade': 'Taper Fade',
    'hard_part_m': 'Hard Part',
    'ivvy_league_m': 'Ivy League',
    'silver_m': 'Bleached Spiky Hair',
    'bald_m': 'Bald Head',
    'frosted_m': 'Frosted',
    'viking_m': 'Viking Undercut',
    // Female examples
    'pixie_cut': 'Pixie Cut',
    'long_hollywood': 'Long Hollywood Waves',
    'afro_female': 'Afro',
    'asymmetrical_bob': 'Asymmetrical Bob',
    'space_buns': 'Space Buns',
    'sleek_high_ponytail': 'Sleek High Ponytail',
    'shag_cut': 'Shag Cut',
    'box_braids': 'Box Braids',
    'edgy_undercut': 'Edgy Undercut',
    'blunt_micro': 'Blunt Micro Bangs',
    // Kids examples
    'classic_crew_cut': 'Classic Crew Cut',
    'textured_crop_with_fringe_child': 'Textured Crop with Fringe',
    'side_part_child': 'Side Part',
    'spiky_hair_child': 'Spiky Hair',
    'fade_with_design_child': 'Fade with Design',
    'caesar_cut_child': 'Caesar Cut',
    'classic_bowl': 'Classic Bowl Cut',
    'spiky_textured': 'Spiky Textured',
    'curly_afro': 'Curly Afro Puff',
    'side_swept_fringe': 'Side-Swept Fringe',
    'messy_surface_hair': 'Messy Surfer Hair',
    'hight_pigtails': 'Pigtails',
    'messy_bun': 'Messy Bun',
    'french_braid_crown': 'French Braid Crown',
    'blunt_cut': 'Bob with Blunt',
    'puffy_half_up': 'Puffy Half-Up',
    'space_buns_fd': 'Space Buns',
    'long_layers_side_bangs_fd': 'Long Layers with Side Bangs',
    'wavy_bob_with_headband_fd': 'Wavy Bob with Headband',
  };

  static Future<List<StyleCategory>> getStyleCategories() async {
    final Map<String, List<String>> grouped = await _loadGroupedAssets();
    return [
      StyleCategory(name: 'Male', styles: grouped['male']!.map(_toItem).toList()),
      StyleCategory(name: 'Female', styles: grouped['female']!.map(_toItem).toList()),
      StyleCategory(name: 'Male Kids', styles: grouped['male_kids']!.map(_toItem).toList()),
      StyleCategory(name: 'Female Kids', styles: grouped['female_kids']!.map(_toItem).toList()),
    ];
  }

  static Future<Map<String, List<String>>> _loadGroupedAssets() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;
    final all = manifestMap.keys.where((k) => k.startsWith(basePath) && (k.endsWith('.png') || k.endsWith('.jpg') ||  k.endsWith('.webp') || k.endsWith('.jpeg'))).toList();

    List<String> male = all.where((p) => p.contains('male/')).toList();
    List<String> female = all.where((p) => p.contains('female/')).toList();
    List<String> maleKids = all.where((p) => p.contains('male_kids/') || p.contains('boys/')).toList();
    List<String> femaleKids = all.where((p) => p.contains('female_kids/') || p.contains('girls/')).toList();

    return {
      'male': male,
      'female': female,
      'male_kids': maleKids,
      'female_kids': femaleKids,
    };
  }

  static String _nameFromPath(String path) {
    final file = path.split('/').last.split('.').first;
    return _displayName[file] ?? file.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  }

  static StyleItem _toItem(String assetPath) {
    final name = _nameFromPath(assetPath);
    return StyleItem(name: name, assetPath: assetPath);
  }
}


