// Extracts metadata (dimensions, format) from image files

import 'dart:io';
import 'package:image/image.dart' as img;

class MetadataExtractor {
  Future<ImageMetadata?> extractImageMetadata(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return null;

      return ImageMetadata(
        width: image.width,
        height: image.height,
        format: _detectFormat(file.path),
      );
    } catch (e) {
      return null;
    }
  }

  String _detectFormat(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      case 'bmp':
        return 'bmp';
      case 'svg':
        return 'svg';
      default:
        return extension;
    }
  }
}

class ImageMetadata {
  final int width;
  final int height;
  final String format;

  ImageMetadata({
    required this.width,
    required this.height,
    required this.format,
  });
}
