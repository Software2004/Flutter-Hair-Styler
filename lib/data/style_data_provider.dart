import '../models/models.dart';

class StyleDataProvider {
  static const String basePath = 'assets/images/hairstyles/';

  static Future<List<StyleCategory>> getStyleCategories() async {
    return [
      StyleCategory(name: 'Male', styles: _getMaleStyles()),
      StyleCategory(name: 'Female', styles: _getFemaleStyles()),
      StyleCategory(name: 'Male Kids', styles: _getMaleKidStyles()),
      StyleCategory(name: 'Female Kids', styles: _getFemaleKidStyles()),
    ];
  }

  static List<StyleItem> _getMaleStyles() {
    return [
      StyleItem(name: 'Undercut', assetPath: '${basePath}undercut_m.webp'),
      StyleItem(name: 'Pompadour', assetPath: '${basePath}popadour_m.webp'),
      StyleItem(name: 'Fade (Skin Fade)', assetPath: '${basePath}fade_m.webp'),
      StyleItem(name: 'Quiff', assetPath: '${basePath}quiff_m.webp'),
      StyleItem(name: 'Side Part', assetPath: '${basePath}side_part_m.webp'),
      StyleItem(name: 'Crew Cut', assetPath: '${basePath}crew_cut_m.webp'),
      StyleItem(name: 'French Crop', assetPath: '${basePath}french_crop_m.webp'),
      StyleItem(name: 'Slicked Back', assetPath: '${basePath}slicked_back_m.webp'),
      StyleItem(name: 'Textured Crop', assetPath: '${basePath}textured_crop.webp'),
      StyleItem(name: 'Man Bun', assetPath: '${basePath}man_bun_m.webp'),
      StyleItem(name: 'Afro', assetPath: '${basePath}afro_m.webp'),
      StyleItem(name: 'Curly Fringe', assetPath: '${basePath}curly_fringe.webp'),
      StyleItem(name: 'Buzz Cut', assetPath: '${basePath}buzz_off_m.webp'),
      StyleItem(name: 'Dreadlocks', assetPath: '${basePath}dread_locks_m.webp'),
      StyleItem(name: 'Comb Over', assetPath: '${basePath}comb_over.webp'),
      StyleItem(name: 'Mullet', assetPath: '${basePath}mullet_m.webp'),
      StyleItem(name: 'Bro Flow', assetPath: '${basePath}bro_flow_m.webp'),
      StyleItem(name: 'Taper Fade', assetPath: '${basePath}taper_fade.webp'),
      StyleItem(name: 'Hard Part', assetPath: '${basePath}hard_part_m.webp'),
      StyleItem(name: 'Ivy League', assetPath: '${basePath}ivvy_league_m.webp'),
      StyleItem(name: 'Bleached Spiky Hair', assetPath: '${basePath}silver_m.webp'),
      StyleItem(name: 'Bald Head', assetPath: '${basePath}bald_m.webp'),
      StyleItem(name: 'Frosted', assetPath: '${basePath}frosted_m.webp'),
      StyleItem(name: 'Viking UnderCut', assetPath: '${basePath}viking_m.webp'),
    ];
  }

  static List<StyleItem> _getFemaleStyles() {
    return [
      StyleItem(name: 'Pixie Cut', assetPath: '${basePath}pixie_cut.webp'),
      StyleItem(name: 'Long Hollywood Waves', assetPath: '${basePath}long_hollywood.webp'),
      StyleItem(name: 'Afro', assetPath: '${basePath}afro_female.webp'),
      StyleItem(name: 'Asymmetrical Bob', assetPath: '${basePath}asymmetrical_bob.webp'),
      StyleItem(name: 'Space Buns', assetPath: '${basePath}space_buns.webp'),
      StyleItem(name: 'Sleek High Ponytail', assetPath: '${basePath}sleek_high_ponytail.webp'),
      StyleItem(name: 'Shag Cut', assetPath: '${basePath}shag_cut.webp'),
      StyleItem(name: 'Box Braids', assetPath: '${basePath}box_braids.webp'),
      StyleItem(name: 'Edgy Undercut', assetPath: '${basePath}edgy_undercut.webp'),
      StyleItem(name: 'Blunt Micro Bangs', assetPath: '${basePath}blunt_micro.webp'),
    ];
  }

  static List<StyleItem> _getFemaleKidStyles() {
    return [
      StyleItem(name: 'Pigtails', assetPath: '${basePath}hight_pigtails.webp'),
      StyleItem(name: 'Messy Bun', assetPath: '${basePath}messy_bun.webp'),
      StyleItem(name: 'French Braid Crown', assetPath: '${basePath}french_braid_crown.webp'),
      StyleItem(name: 'Bob with Blunt', assetPath: '${basePath}blunt_cut.webp'),
      StyleItem(name: 'Puffy Half-Up', assetPath: '${basePath}puffy_half_up.webp'),
      StyleItem(name: 'Space Buns', assetPath: '${basePath}space_buns_fd.webp'),
      StyleItem(name: 'Long Layers with Side Bangs', assetPath: '${basePath}long_layers_side_bangs_fd.webp'),
      StyleItem(name: 'Wavy Bob with Headband', assetPath: '${basePath}wavy_bob_with_headband_fd.webp'),
    ];
  }

  static List<StyleItem> _getMaleKidStyles() {
    return [
      StyleItem(name: 'Classic Crew Cut', assetPath: '${basePath}classic_crew_cut.webp'),
      StyleItem(name: 'Textured Crop with Fringe', assetPath: '${basePath}textured_crop_with_fringe_child.webp'),
      StyleItem(name: 'Side Part', assetPath: '${basePath}side_part_child.webp'),
      StyleItem(name: 'Spiky Hair', assetPath: '${basePath}spiky_hair_child.webp'),
      StyleItem(name: 'Fade with Design', assetPath: '${basePath}fade_with_design_child.webp'),
      StyleItem(name: 'Caesar Cut', assetPath: '${basePath}caesar_cut_child.webp'),
      StyleItem(name: 'Classic Bowl Cut', assetPath: '${basePath}classic_bowl.webp'),
      StyleItem(name: 'Spiky Textured', assetPath: '${basePath}spiky_textured.webp'),
      StyleItem(name: 'Curly Afro Puff', assetPath: '${basePath}curly_afro.webp'),
      StyleItem(name: 'Side-Swept Fringe', assetPath: '${basePath}side_swept_fringe.webp'),
      StyleItem(name: 'Messy Surfer Hair', assetPath: '${basePath}messy_surface_hair.webp'),
    ];
  }
}


