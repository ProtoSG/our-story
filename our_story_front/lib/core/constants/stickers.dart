class Stickers {
  static const String basePath = 'assets/images/stickers/';
  
  static const List<String> availableStickers = [
    'sticker_001',
    'sticker_002',
    'sticker_003',
  ];
  
  static String getPath(String stickerName) {
    return '$basePath$stickerName.png';
  }
  
  static String? getStickerName(String path) {
    if (!path.startsWith(basePath)) return null;
    return path.replaceFirst(basePath, '').replaceFirst('.png', '');
  }
}
