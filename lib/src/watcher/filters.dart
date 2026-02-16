// File type and pattern filters for asset watcher.

class FileFilter {
  static const imageExtensions = [
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.webp',
    '.svg',
    '.bmp',
    '.ico',
  ];

  static const fontExtensions = [
    '.ttf',
    '.otf',
    '.woff',
    '.woff2',
  ];

  static const videoExtensions = [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.webm',
  ];

  static const dataExtensions = [
    '.json',
    '.xml',
    '.yaml',
    '.yml',
    '.csv',
  ];

  static bool isImage(String path) =>
      imageExtensions.any((ext) => path.toLowerCase().endsWith(ext));

  static bool isFont(String path) =>
      fontExtensions.any((ext) => path.toLowerCase().endsWith(ext));

  static bool isVideo(String path) =>
      videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));

  static bool isData(String path) =>
      dataExtensions.any((ext) => path.toLowerCase().endsWith(ext));

  static bool isAsset(String path) =>
      isImage(path) || isFont(path) || isVideo(path) || isData(path);
}

class PatternFilter {
  static final ignorePatterns = [
    RegExp(r'/\.[^/]+$'), // Hidden files
    RegExp(r'~$'), // Temp files
    RegExp(r'\.tmp$'), // Temp files
    RegExp(r'\.DS_Store$'), // macOS
    RegExp(r'Thumbs\.db$'), // Windows
    RegExp(r'\.git/'), // Git directory
    RegExp(r'node_modules/'), // Node modules
    RegExp(r'\.idea/'), // IDE
    RegExp(r'\.vscode/'), // VS Code
  ];

  static bool shouldIgnore(String path) =>
      ignorePatterns.any((pattern) => pattern.hasMatch(path));
}
