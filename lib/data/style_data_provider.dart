import '../models/models.dart';
import 'prompts_data.dart';

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
      StyleItem(name: 'Undercut', assetPath: '${basePath}undercut_m.webp', prompt: kStylePrompts['Undercut'] ?? ''),
      StyleItem(name: 'Pompadour', assetPath: '${basePath}popadour_m.webp', prompt: kStylePrompts['Pompadour'] ?? ''),
      StyleItem(name: 'Fade (Skin Fade)', assetPath: '${basePath}fade_m.webp', prompt: kStylePrompts['Fade (Skin Fade)'] ?? ''),
      StyleItem(name: 'Quiff', assetPath: '${basePath}quiff_m.webp', prompt: kStylePrompts['Quiff'] ?? ''),
      StyleItem(name: 'Side Part', assetPath: '${basePath}side_part_m.webp', prompt: kStylePrompts['Side Part'] ?? ''),
      StyleItem(name: 'Crew Cut', assetPath: '${basePath}crew_cut_m.webp', prompt: kStylePrompts['Crew Cut'] ?? ''),
      StyleItem(name: 'French Crop', assetPath: '${basePath}french_crop_m.webp', prompt: kStylePrompts['French Crop'] ?? ''),
      StyleItem(name: 'Slicked Back', assetPath: '${basePath}slicked_back_m.webp', prompt: kStylePrompts['Slicked Back'] ?? ''),
      StyleItem(name: 'Textured Crop', assetPath: '${basePath}textured_crop.webp', prompt: kStylePrompts['Textured Crop'] ?? ''),
      StyleItem(name: 'Man Bun', assetPath: '${basePath}man_bun_m.webp', prompt: kStylePrompts['Man Bun'] ?? ''),
      StyleItem(name: 'Afro', assetPath: '${basePath}afro_m.webp', prompt: kStylePrompts['Afro'] ?? ''),
      StyleItem(name: 'Curly Fringe', assetPath: '${basePath}curly_fringe.webp', prompt: kStylePrompts['Curly Fringe'] ?? ''),
      StyleItem(name: 'Buzz Cut', assetPath: '${basePath}buzz_off_m.webp', prompt: kStylePrompts['Buzz Cut'] ?? ''),
      StyleItem(name: 'Dreadlocks', assetPath: '${basePath}dread_locks_m.webp', prompt: kStylePrompts['Dreadlocks'] ?? ''),
      StyleItem(name: 'Comb Over', assetPath: '${basePath}comb_over.webp', prompt: kStylePrompts['Comb Over'] ?? ''),
      StyleItem(name: 'Mullet', assetPath: '${basePath}mullet_m.webp', prompt: kStylePrompts['Mullet'] ?? ''),
      StyleItem(name: 'Bro Flow', assetPath: '${basePath}bro_flow_m.webp', prompt: kStylePrompts['Bro Flow'] ?? ''),
      StyleItem(name: 'Taper Fade', assetPath: '${basePath}taper_fade.webp', prompt: kStylePrompts['Taper Fade'] ?? ''),
      StyleItem(name: 'Hard Part', assetPath: '${basePath}hard_part_m.webp', prompt: kStylePrompts['Hard Part'] ?? ''),
      StyleItem(name: 'Ivy League', assetPath: '${basePath}ivvy_league_m.webp', prompt: kStylePrompts['Ivy League'] ?? ''),
      StyleItem(name: 'Bleached Spiky Hair', assetPath: '${basePath}silver_m.webp', prompt: kStylePrompts['Bleached Spiky Hair'] ?? ''),
      StyleItem(name: 'Bald Head', assetPath: '${basePath}bald_m.webp', prompt: kStylePrompts['Bald Head'] ?? ''),
      StyleItem(name: 'Frosted', assetPath: '${basePath}frosted_m.webp', prompt: kStylePrompts['Frosted'] ?? ''),
      StyleItem(name: 'Viking UnderCut', assetPath: '${basePath}viking_m.webp', prompt: kStylePrompts['Viking UnderCut'] ?? ''),
    ];
  }

  static List<StyleItem> _getFemaleStyles() {
    return [
      StyleItem(name: 'Pixie Cut', assetPath: '${basePath}pixie_cut.webp', prompt: kStylePrompts['Pixie Cut'] ?? ''),
      StyleItem(name: 'Long Hollywood Waves', assetPath: '${basePath}long_hollywood.webp', prompt: kStylePrompts['Long Hollywood Waves'] ?? ''),
      StyleItem(name: 'Afro', assetPath: '${basePath}afro_female.webp', prompt: kStylePrompts['Afro (Female)'] ?? ''),
      StyleItem(name: 'Asymmetrical Bob', assetPath: '${basePath}asymmetrical_bob.webp', prompt: kStylePrompts['Asymmetrical Bob'] ?? ''),
      StyleItem(name: 'Space Buns', assetPath: '${basePath}space_buns.webp', prompt: kStylePrompts['Space Buns (Female)'] ?? ''),
      StyleItem(name: 'Sleek High Ponytail', assetPath: '${basePath}sleek_high_ponytail.webp', prompt: kStylePrompts['Sleek High Ponytail'] ?? ''),
      StyleItem(name: 'Shag Cut', assetPath: '${basePath}shag_cut.webp', prompt: kStylePrompts['Shag Cut'] ?? ''),
      StyleItem(name: 'Box Braids', assetPath: '${basePath}box_braids.webp', prompt: kStylePrompts['Box Braids'] ?? ''),
      StyleItem(name: 'Edgy Undercut', assetPath: '${basePath}edgy_undercut.webp', prompt: kStylePrompts['Edgy Undercut (Female)'] ?? ''),
      StyleItem(name: 'Blunt Micro Bangs', assetPath: '${basePath}blunt_micro.webp', prompt: kStylePrompts['Blunt Micro Bangs'] ?? ''),
    ];
  }

  static List<StyleItem> _getFemaleKidStyles() {
    return [
      StyleItem(name: 'Pigtails', assetPath: '${basePath}hight_pigtails.webp', prompt: kStylePrompts['Pigtails'] ?? ''),
      StyleItem(name: 'Messy Bun', assetPath: '${basePath}messy_bun.webp', prompt: kStylePrompts['Messy Bun (Girl)'] ?? ''),
      StyleItem(name: 'French Braid Crown', assetPath: '${basePath}french_braid_crown.webp', prompt: kStylePrompts['French Braid Crown'] ?? ''),
      StyleItem(name: 'Bob with Blunt', assetPath: '${basePath}blunt_cut.webp', prompt: kStylePrompts['Bob with Blunt'] ?? ''),
      StyleItem(name: 'Puffy Half-Up', assetPath: '${basePath}puffy_half_up.webp', prompt: kStylePrompts['Puffy Half-Up'] ?? ''),
      StyleItem(name: 'Space Buns', assetPath: '${basePath}space_buns_fd.webp', prompt: kStylePrompts['Space Buns (Girl)'] ?? ''),
      StyleItem(name: 'Long Layers with Side Bangs', assetPath: '${basePath}long_layers_side_bangs_fd.webp', prompt: kStylePrompts['Long Layers with Side Bangs'] ?? ''),
      StyleItem(name: 'Wavy Bob with Headband', assetPath: '${basePath}wavy_bob_with_headband_fd.webp', prompt: kStylePrompts['Wavy Bob with Headband'] ?? ''),
    ];
  }

  static List<StyleItem> _getMaleKidStyles() {
    return [
      StyleItem(name: 'Classic Crew Cut', assetPath: '${basePath}classic_crew_cut.webp', prompt: kStylePrompts['Classic Crew Cut'] ?? ''),
      StyleItem(name: 'Textured Crop with Fringe', assetPath: '${basePath}textured_crop_with_fringe_child.webp', prompt: kStylePrompts['Textured Crop with Fringe'] ?? ''),
      StyleItem(name: 'Side Part', assetPath: '${basePath}side_part_child.webp', prompt: kStylePrompts['Side Part (Boy)'] ?? ''),
      StyleItem(name: 'Spiky Hair', assetPath: '${basePath}spiky_hair_child.webp', prompt: kStylePrompts['Spiky Hair (Boy)'] ?? ''),
      StyleItem(name: 'Fade with Design', assetPath: '${basePath}fade_with_design_child.webp', prompt: kStylePrompts['Fade with Design'] ?? ''),
      StyleItem(name: 'Caesar Cut', assetPath: '${basePath}caesar_cut_child.webp', prompt: kStylePrompts['Caesar Cut'] ?? ''),
      StyleItem(name: 'Classic Bowl Cut', assetPath: '${basePath}classic_bowl.webp', prompt: kStylePrompts['Classic Bowl Cut'] ?? ''),
      StyleItem(name: 'Spiky Textured', assetPath: '${basePath}spiky_textured.webp', prompt: kStylePrompts['Spiky Textured'] ?? ''),
      StyleItem(name: 'Curly Afro Puff', assetPath: '${basePath}curly_afro.webp', prompt: kStylePrompts['Curly Afro Puff (Boy)'] ?? ''),
      StyleItem(name: 'Side-Swept Fringe', assetPath: '${basePath}side_swept_fringe.webp', prompt: kStylePrompts['Side-Swept Fringe'] ?? ''),
      StyleItem(name: 'Messy Surfer Hair', assetPath: '${basePath}messy_surface_hair.webp', prompt: kStylePrompts['Messy Surfer Hair'] ?? ''),
    ];
  }
}


