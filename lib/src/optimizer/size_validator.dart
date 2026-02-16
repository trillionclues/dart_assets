// Validate asset files meet size constraints

import 'dart:io';
import 'package:path/path.dart' as p;

class SizeValidator {
  // max file size in bytes (default: 500KB)
  final int maxFileSizeBytes;

  SizeValidator({int maxFileSizeKB = 500})
      : maxFileSizeBytes = maxFileSizeKB * 1024;

  Future<List<SizeViolation>> validate(Directory assetsDir) async {
    final violations = <SizeViolation>[];

    if (!assetsDir.existsSync()) return violations;

    await for (final entity in assetsDir.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.size > maxFileSizeBytes) {
          violations.add(SizeViolation(
            path: p.relative(entity.path, from: assetsDir.parent.path),
            actualSize: stat.size,
            maxSize: maxFileSizeBytes,
          ));
        }
      }
    }

    return violations;
  }
}

class SizeViolation {
  final String path;
  final int actualSize;
  final int maxSize;

  SizeViolation({
    required this.path,
    required this.actualSize,
    required this.maxSize,
  });

  String get humanReadableSize => _formatBytes(actualSize);
  String get humanReadableMax => _formatBytes(maxSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
