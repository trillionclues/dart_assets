# ASSET OPTIMIZATION

## Overview

Optimizing assets reduces app size and improves performance. This document covers image compression, format conversion, and size limits.

---

## Why Optimize?

### Impact of Unoptimized Assets

**Example: E-commerce app**
```
Unoptimized:
  50 product images × 2MB each = 100MB
  App size: 110MB total
  Download time (4G): ~2 minutes
  Users who abandon: ~60%

Optimized:
  50 product images × 100KB each = 5MB
  App size: 15MB total
  Download time (4G): ~8 seconds
  Users who abandon: ~10%
```

**ROI:**
- 95% size reduction
- 15x faster downloads
- 6x more installs

---

## Image Formats Comparison

| Format | Best For | Pros | Cons |
|--------|----------|------|------|
| **PNG** | Icons, logos, transparency | Lossless, transparency | Large file size |
| **JPEG** | Photos, complex images | Small size, good quality | No transparency, lossy |
| **WebP** | All images | Small size + transparency | Limited support (iOS 14+) |
| **SVG** | Icons, simple graphics | Scalable, tiny size | CPU intensive rendering |

### Format Recommendations
```dart
class FormatRecommender {
  String recommendFormat(File imageFile) {
    // Check if has transparency
    if (_hasTransparency(imageFile)) {
      // Transparent images
      if (_isSimple(imageFile)) {
        return 'svg';   // Simple icon → SVG
      } else {
        return 'webp';  // Complex → WebP
      }
    } else {
      // No transparency
      if (_isPhoto(imageFile)) {
        return 'jpeg';  // Photo → JPEG
      } else {
        return 'webp';  // Everything else → WebP
      }
    }
  }
}
```

---

## PNG Optimization

### Lossless Compression

**Using `image` package:**
```dart
// lib/src/optimizer/png_optimizer.dart
import 'dart:io';
import 'package:image/image.dart' as img;

class PngOptimizer {
  Future<OptimizationResult> optimize(File pngFile) async {
    final originalSize = await pngFile.length();
    
    // Read image
    final bytes = await pngFile.readAsBytes();
    final image = img.decodePng(bytes);
    
    if (image == null) {
      throw InvalidImageError('Failed to decode PNG');
    }
    
    // Re-encode with optimal settings
    final optimized = img.encodePng(
      image,
      level: 9,  // Maximum compression (0-9)
    );
    
    // Write optimized version
    await pngFile.writeAsBytes(optimized);
    
    final newSize = optimized.length;
    
    return OptimizationResult(
      originalSize: originalSize,
      newSize: newSize,
      savedBytes: originalSize - newSize,
      savedPercent: ((originalSize - newSize) / originalSize * 100).round(),
    );
  }
}

class OptimizationResult {
  final int originalSize;
  final int newSize;
  final int savedBytes;
  final int savedPercent;
  
  OptimizationResult({
    required this.originalSize,
    required this.newSize,
    required this.savedBytes,
    required this.savedPercent,
  });
}
```

### Advanced PNG Optimization

**Using external tools (better compression):**
```dart
class AdvancedPngOptimizer {
  Future<OptimizationResult> optimize(File pngFile) async {
    // Use pngquant for lossy compression (better results)
    final result = await Process.run('pngquant', [
      '--quality=65-80',    // Quality range
      '--speed=1',          // Slow but best quality
      '--force',            // Overwrite existing
      '--ext=.png',         // Keep extension
      pngFile.path,
    ]);
    
    if (result.exitCode != 0) {
      throw OptimizationError('pngquant failed: ${result.stderr}');
    }
    
    // Then use optipng for lossless cleanup
    await Process.run('optipng', [
      '-o7',                // Maximum optimization
      '-strip all',         // Remove metadata
      pngFile.path,
    ]);
    
    return _calculateSavings(originalSize, await pngFile.length());
  }
}
```

**Install tools:**
```bash
# macOS
brew install pngquant optipng

# Linux
apt-get install pngquant optipng

# Windows
choco install pngquant optipng
```

---

## JPEG Optimization
```dart
// lib/src/optimizer/jpeg_optimizer.dart
class JpegOptimizer {
  Future<OptimizationResult> optimize(
    File jpegFile, {
    int quality = 85,  // 0-100, sweet spot is 85
  }) async {
    final originalSize = await jpegFile.length();
    
    final bytes = await jpegFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw InvalidImageError('Failed to decode JPEG');
    }
    
    // Re-encode with specified quality
    final optimized = img.encodeJpg(image, quality: quality);
    
    await jpegFile.writeAsBytes(optimized);
    
    final newSize = optimized.length;
    
    return OptimizationResult(
      originalSize: originalSize,
      newSize: newSize,
      savedBytes: originalSize - newSize,
      savedPercent: ((originalSize - newSize) / originalSize * 100).round(),
    );
  }
}
```

### Quality vs Size Trade-off
```
Quality 95: 500 KB (visually identical)
Quality 90: 300 KB (imperceptible difference)
Quality 85: 200 KB (slight difference) ← RECOMMENDED
Quality 80: 150 KB (noticeable at full size)
Quality 70: 100 KB (visible artifacts)
Quality 50:  50 KB (poor quality)
```

**Recommendation:** Use 85 for photos, 90 for marketing materials.

---

## WebP Conversion

### Why WebP?

- **25-35% smaller** than JPEG at same quality
- **26% smaller** than PNG for transparency
- Supports both lossy and lossless
- Supported: Android (all), iOS 14+

### Implementation
```dart
// lib/src/optimizer/webp_converter.dart
class WebPConverter {
  Future<ConversionResult> convert(
    File imageFile, {
    int quality = 80,
    bool lossless = false,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw InvalidImageError('Failed to decode image');
    }
    
    // Encode as WebP
    final webp = img.encodeWebP(
      image,
      quality: lossless ? 100 : quality,
    );
    
    // Create new file with .webp extension
    final webpPath = imageFile.path.replaceAll(
      RegExp(r'\.(png|jpg|jpeg)$'),
      '.webp',
    );
    
    final webpFile = File(webpPath);
    await webpFile.writeAsBytes(webp);
    
    return ConversionResult(
      originalFile: imageFile,
      newFile: webpFile,
      originalSize: await imageFile.length(),
      newSize: webp.length,
    );
  }
}
```

### Batch Conversion
```dart
class BatchWebPConverter {
  Future<List<ConversionResult>> convertDirectory(
    Directory dir, {
    bool deleteOriginals = false,
  }) async {
    final results = <ConversionResult>[];
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && _isConvertible(entity.path)) {
        final result = await _converter.convert(entity);
        results.add(result);
        
        // Optionally delete originals
        if (deleteOriginals && result.savedBytes > 0) {
          await entity.delete();
        }
      }
    }
    
    return results;
  }
  
  bool _isConvertible(String path) {
    return path.endsWith('.png') || 
           path.endsWith('.jpg') || 
           path.endsWith('.jpeg');
  }
}
```

---

## Image Resizing

### Downscale Large Images
```dart
class ImageResizer {
  Future<void> resizeIfNeeded(
    File imageFile, {
    int maxWidth = 2048,
    int maxHeight = 2048,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) return;
    
    // Check if resize needed
    if (image.width <= maxWidth && image.height <= maxHeight) {
      return; // Already small enough
    }
    
    // Calculate new dimensions (maintain aspect ratio)
    final ratio = image.width / image.height;
    int newWidth, newHeight;
    
    if (ratio > 1) {
      // Landscape
      newWidth = maxWidth;
      newHeight = (maxWidth / ratio).round();
    } else {
      // Portrait
      newHeight = maxHeight;
      newWidth = (maxHeight * ratio).round();
    }
    
    // Resize
    final resized = img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.average,
    );
    
    // Save
    final extension = imageFile.path.split('.').last.toLowerCase();
    List<int> encoded;
    
    if (extension == 'png') {
      encoded = img.encodePng(resized);
    } else {
      encoded = img.encodeJpg(resized, quality: 85);
    }
    
    await imageFile.writeAsBytes(encoded);
  }
}
```

### Recommended Sizes
```dart
class ImageSizeRecommendations {
  static const maxProductImage = 1024;     // E-commerce
  static const maxHeroImage = 1920;        // Hero banners
  static const maxThumbnail = 256;         // Thumbnails
  static const maxIcon = 512;              // Icons/logos
  
  static int recommendedSize(String assetType) {
    switch (assetType) {
      case 'product': return maxProductImage;
      case 'hero': return maxHeroImage;
      case 'thumbnail': return maxThumbnail;
      case 'icon': return maxIcon;
      default: return 2048;
    }
  }
}
```

---

## Size Validation

### Enforce Size Limits
```dart
// lib/src/optimizer/size_validator.dart
class SizeValidator {
  final int maxFileSizeBytes;
  
  SizeValidator({
    this.maxFileSizeBytes = 500 * 1024, // 500 KB default
  });
  
  Future<List<OversizedAsset>> findOversizedAssets(Directory assetsDir) async {
    final oversized = <OversizedAsset>[];
    
    await for (final entity in assetsDir.list(recursive: true)) {
      if (entity is File) {
        final size = await entity.length();
        
        if (size > maxFileSizeBytes) {
          oversized.add(OversizedAsset(
            file: entity,
            size: size,
            limit: maxFileSizeBytes,
          ));
        }
      }
    }
    
    return oversized;
  }
}

class OversizedAsset {
  final File file;
  final int size;
  final int limit;
  
  OversizedAsset({
    required this.file,
    required this.size,
    required this.limit,
  });
  
  int get excessBytes => size - limit;
  int get excessPercent => ((excessBytes / limit) * 100).round();
}
```

---

## Complete Optimizer
```dart
// lib/src/optimizer/image_optimizer.dart
class ImageOptimizer {
  final PngOptimizer _pngOptimizer = PngOptimizer();
  final JpegOptimizer _jpegOptimizer = JpegOptimizer();
  final WebPConverter _webpConverter = WebPConverter();
  final ImageResizer _resizer = ImageResizer();
  
  Future<OptimizationSummary> optimizeAll(Directory assetsDir) async {
    final summary = OptimizationSummary();
    
    await for (final entity in assetsDir.list(recursive: true)) {
      if (entity is! File) continue;
      
      final result = await _optimizeFile(entity);
      summary.add(result);
    }
    
    return summary;
  }
  
  Future<FileOptimizationResult> _optimizeFile(File file) async {
    final extension = file.path.split('.').last.toLowerCase();
    
    // Step 1: Resize if needed
    await _resizer.resizeIfNeeded(file);
    
    // Step 2: Optimize based on format
    OptimizationResult? result;
    
    switch (extension) {
      case 'png':
        result = await _pngOptimizer.optimize(file);
        break;
      case 'jpg':
      case 'jpeg':
        result = await _jpegOptimizer.optimize(file);
        break;
    }
    
    // Step 3: Consider WebP conversion
    if (['png', 'jpg', 'jpeg'].contains(extension)) {
      final webpResult = await _webpConverter.convert(file);
      
      // Use WebP if significantly smaller
      if (webpResult.savedBytes > 10 * 1024) { // 10KB threshold
        return FileOptimizationResult(
          file: file,
          action: 'Converted to WebP',
          result: result,
        );
      }
    }
    
    return FileOptimizationResult(
      file: file,
      action: 'Optimized',
      result: result,
    );
  }
}

class OptimizationSummary {
  final List<FileOptimizationResult> results = [];
  
  void add(FileOptimizationResult result) {
    results.add(result);
  }
  
  int get totalSavedBytes {
    return results.fold<int>(
      0,
      (sum, r) => sum + (r.result?.savedBytes ?? 0),
    );
  }
  
  int get filesOptimized => results.length;
  
  String get summary {
    final savedMB = totalSavedBytes / (1024 * 1024);
    return 'Optimized $filesOptimized files, saved ${savedMB.toStringAsFixed(1)} MB';
  }
}
```

---

## CLI Integration

### Optimize Command
```dart
// lib/src/cli/commands/optimize_command.dart
class OptimizeCommand extends Command {
  @override
  String get name => 'optimize';
  
  @override
  String get description => 'Optimize images for production';
  
  OptimizeCommand() {
    argParser.addFlag(
      'webp',
      help: 'Convert images to WebP format',
      defaultsTo: false,
    );
    
    argParser.addOption(
      'quality',
      help: 'JPEG quality (0-100)',
      defaultsTo: '85',
    );
    
    argParser.addFlag(
      'dry-run',
      help: 'Show what would be optimized without making changes',
      defaultsTo: false,
    );
  }
  
  @override
  Future<void> run() async {
    final projectRoot = Directory.current;
    final assetsDir = Directory('${projectRoot.path}/assets');
    
    if (!assetsDir.existsSync()) {
      print('❌ Assets directory not found');
      return;
    }
    
    final dryRun = argResults!['dry-run'] as bool;
    final convertWebP = argResults!['webp'] as bool;
    
    print('🔍 Scanning assets for optimization...\n');
    
    final optimizer = ImageOptimizer();
    final summary = await optimizer.optimizeAll(assetsDir);
    
    // Display results
    _displayResults(summary);
    
    if (dryRun) {
      print('\n💡 This was a dry run. No files were modified.');
      print('   Run without --dry-run to apply optimizations.');
      return;
    }
    
    // Confirm
    print('\nApply optimizations? [y/N]: ');
    final input = stdin.readLineSync();
    
    if (input?.toLowerCase() != 'y') {
      print('Cancelled!!!');
      return;
    }
    
    // Apply optimizations
    print('\n => Optimizing...');
    // ... actual optimization
    
    print('\n Done!');
    print('💾 Saved ${summary.totalSavedBytes} bytes');
  }
  
  void _displayResults(OptimizationSummary summary) {
    for (final result in summary.results) {
      if (result.result == null) continue;
      
      final filename = result.file.path.split('/').last;
      final saved = result.result!.savedBytes;
      final percent = result.result!.savedPercent;
      
      print('  => $filename');
      print('     Saved: ${_formatBytes(saved)} ($percent%)');
    }
    
    print('\n Total savings: ${_formatBytes(summary.totalSavedBytes)}');
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

---

## Best Practices

### 1. Always Backup Before Optimization
```dart
class SafeOptimizer {
  Future<void> optimizeWithBackup(File file) async {
    // Create backup
    final backupPath = '${file.path}.backup';
    await file.copy(backupPath);
    
    try {
      // Optimize
      await _optimize(file);
      
      // Delete backup on success
      await File(backupPath).delete();
    } catch (e) {
      // Restore backup on error
      await File(backupPath).copy(file.path);
      await File(backupPath).delete();
      rethrow;
    }
  }
}
```

### 2. Use Progressive JPEGs
```dart
final optimized = img.encodeJpg(
  image,
  quality: 85,
  // Progressive encoding (better for web)
  // Note: Not supported in image package v4.x
  // Use external tools like jpegtran instead
);
```

### 3. Remove Metadata
```dart
class MetadataStripper {
  Future<void> stripExif(File imageFile) async {
    // EXIF data can add 10-50 KB
    await Process.run('exiftool', [
      '-all=',           // Remove all metadata
      '-overwrite_original',
      imageFile.path,
    ]);
  }
}
```

### 4. Test on Real Devices

Different platforms handle images differently:
- iOS uses hardware-accelerated JPEG/PNG
- Android may be slower with large PNGs
- WebP decoding is slower than JPEG

**Always test:**
- Load time
- Memory usage
- Rendering performance

---

## Optimization Checklist
```
Before Release:
☐ All images under 500 KB
☐ Photos are JPEG (quality 85)
☐ Icons/logos are PNG or SVG
☐ Consider WebP for modern apps (iOS 14+)
☐ No images larger than 2048px
☐ Metadata stripped
☐ Test on slowest target device
☐ Measure app size impact
```

---

## Performance Monitoring
```dart
class OptimizationMetrics {
  static Future<AppSizeReport> generateReport(Directory project) async {
    final assetsDir = Directory('${project.path}/assets');
    
    int totalSize = 0;
    int imageCount = 0;
    int oversizedCount = 0;
    
    await for (final entity in assetsDir.list(recursive: true)) {
      if (entity is File && _isImage(entity.path)) {
        final size = await entity.length();
        totalSize += size;
        imageCount++;
        
        if (size > 500 * 1024) {
          oversizedCount++;
        }
      }
    }
    
    return AppSizeReport(
      totalAssetSize: totalSize,
      imageCount: imageCount,
      oversizedCount: oversizedCount,
      averageSize: imageCount > 0 ? totalSize ~/ imageCount : 0,
    );
  }
}
```