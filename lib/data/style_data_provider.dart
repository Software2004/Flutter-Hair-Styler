import 'dart:convert';
import 'package:flutter/foundation.dart';
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

    // Debug: Print all found assets
    debugPrint('Found ${all.length} assets in manifest');
    for (var asset in all) {
      debugPrint('Asset: $asset');
    }

    // Categorize based on filename patterns since assets are in flat structure
    List<String> male = all.where((p) => _isMaleAsset(p)).toList();
    List<String> female = all.where((p) => _isFemaleAsset(p)).toList();
    List<String> maleKids = all.where((p) => _isMaleKidsAsset(p)).toList();
    List<String> femaleKids = all.where((p) => _isFemaleKidsAsset(p)).toList();

    // Debug: Print categorized assets
    debugPrint('Male assets: ${male.length}');
    debugPrint('Female assets: ${female.length}');
    debugPrint('Male Kids assets: ${maleKids.length}');
    debugPrint('Female Kids assets: ${femaleKids.length}');

    return {
      'male': male,
      'female': female,
      'male_kids': maleKids,
      'female_kids': femaleKids,
    };
  }

  // Helper methods to categorize assets based on filename patterns
  static bool _isMaleAsset(String path) {
    final filename = path.split('/').last.toLowerCase();
    return filename.contains('_m.') || 
           filename.contains('undercut_m') ||
           filename.contains('popadour_m') ||
           filename.contains('fade_m') ||
           filename.contains('quiff_m') ||
           filename.contains('side_part_m') ||
           filename.contains('crew_cut_m') ||
           filename.contains('french_crop_m') ||
           filename.contains('slicked_back_m') ||
           filename.contains('man_bun_m') ||
           filename.contains('afro_m') ||
           filename.contains('buzz_off_m') ||
           filename.contains('dread_locks_m') ||
           filename.contains('comb_over') ||
           filename.contains('mullet_m') ||
           filename.contains('bro_flow_m') ||
           filename.contains('taper_fade') ||
           filename.contains('hard_part_m') ||
           filename.contains('ivvy_league_m') ||
           filename.contains('silver_m') ||
           filename.contains('bald_m') ||
           filename.contains('frosted_m') ||
           filename.contains('viking_m');
  }

  static bool _isFemaleAsset(String path) {
    final filename = path.split('/').last.toLowerCase();
    return filename.contains('_f.') ||
           filename.contains('pixie_cut') ||
           filename.contains('long_hollywood') ||
           filename.contains('afro_female') ||
           filename.contains('asymmetrical_bob') ||
           filename.contains('space_buns') ||
           filename.contains('sleek_high_ponytail') ||
           filename.contains('shag_cut') ||
           filename.contains('box_braids') ||
           filename.contains('edgy_undercut') ||
           filename.contains('blunt_micro') ||
           filename.contains('space_buns_fd') ||
           filename.contains('long_layers_side_bangs_fd') ||
           filename.contains('wavy_bob_with_headband_fd');
  }

  static bool _isMaleKidsAsset(String path) {
    final filename = path.split('/').last.toLowerCase();
    return filename.contains('_child') ||
           filename.contains('classic_crew_cut') ||
           filename.contains('textured_crop_with_fringe_child') ||
           filename.contains('side_part_child') ||
           filename.contains('spiky_hair_child') ||
           filename.contains('fade_with_design_child') ||
           filename.contains('caesar_cut_child');
  }

  static bool _isFemaleKidsAsset(String path) {
    final filename = path.split('/').last.toLowerCase();
    return filename.contains('classic_bowl') ||
           filename.contains('spiky_textured') ||
           filename.contains('curly_afro') ||
           filename.contains('side_swept_fringe') ||
           filename.contains('messy_surface_hair') ||
           filename.contains('hight_pigtails') ||
           filename.contains('messy_bun') ||
           filename.contains('french_braid_crown') ||
           filename.contains('blunt_cut') ||
           filename.contains('puffy_half_up');
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


