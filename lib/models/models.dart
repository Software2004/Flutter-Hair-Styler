class StyleItem {
  final String name;
  final String assetPath;
  final String prompt;

  const StyleItem({required this.name, required this.assetPath, this.prompt = ''});
}

class StyleCategory {
  final String name;
  final List<StyleItem> styles;

  const StyleCategory({required this.name, required this.styles});
}


