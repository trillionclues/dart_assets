// Optimize images by compressing, resizing, and converting formats

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class ImageOptimizer {
  final int jpegQuality;
  final bool convertToWebP;

  ImageOptimizer({
    this.jpegQuality = 85,
    this.convertToWebP = false,
  });

  // optimize single image file and return the bytes saved
  Future<OptimizeResult> optimize(File file) async {
    final originalSize = await file.length();
    final extension = p.extension(file.path).toLowerCase();

    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      return OptimizeResult(file: file, saved: 0, skipped: true);
    }

    late List<int> optimizedBytes;

    if (convertToWebP) {
      // TODO: The `image` package does not include a WebP encoder.
      // maybe an external tool (e.g. cwebp) or a dedicated WebP package.
      return OptimizeResult(file: file, saved: 0, skipped: true);
    }

    switch (extension) {
      case '.png':
        optimizedBytes = img.encodePng(image, level: 6);
        break;
      case '.jpg':
      case '.jpeg':
        optimizedBytes = img.encodeJpg(image, quality: jpegQuality);
        break;
      default:
        return OptimizeResult(file: file, saved: 0, skipped: true);
    }

    if (optimizedBytes.length < originalSize) {
      await file.writeAsBytes(optimizedBytes);
      return OptimizeResult(
        file: file,
        saved: originalSize - optimizedBytes.length,
        skipped: false,
      );
    }

    return OptimizeResult(file: file, saved: 0, skipped: true);
  }
}

class OptimizeResult {
  final File file;
  final int saved;
  final bool skipped;

  OptimizeResult({
    required this.file,
    required this.saved,
    this.skipped = false,
  });
}
