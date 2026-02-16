import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_assets/src/generator/asset_scanner.dart';

void main() {
  group('AssetScanner', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('asset_scanner_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('scans images from assets directory', () async {
      // Create test assets
      final imagesDir = Directory('${tempDir.path}/assets/images');
      imagesDir.createSync(recursive: true);
      File('${imagesDir.path}/logo.png').writeAsBytesSync([0x89, 0x50]);
      File('${imagesDir.path}/banner.jpg').writeAsBytesSync([0xFF, 0xD8]);

      final scanner = AssetScanner(projectRoot: tempDir);
      final assets = await scanner.scan();

      expect(assets, hasLength(2));
      expect(
        assets.map((a) => a.name),
        containsAll(['logo', 'banner']),
      );
    });

    test('returns empty list when no assets dir', () async {
      final scanner = AssetScanner(projectRoot: tempDir);
      final assets = await scanner.scan();

      expect(assets, isEmpty);
    });

    test('ignores non-asset files', () async {
      final assetsDir = Directory('${tempDir.path}/assets');
      assetsDir.createSync(recursive: true);
      File('${assetsDir.path}/readme.md').writeAsStringSync('# Hi');
      File('${assetsDir.path}/logo.png').writeAsBytesSync([0x89, 0x50]);

      final scanner = AssetScanner(projectRoot: tempDir);
      final assets = await scanner.scan();

      expect(assets, hasLength(1));
      expect(assets.first.name, equals('logo'));
    });

    test('scans recursively and sorts by path', () async {
      Directory('${tempDir.path}/assets/images').createSync(recursive: true);
      Directory('${tempDir.path}/assets/icons').createSync(recursive: true);

      File('${tempDir.path}/assets/images/photo.jpg')
          .writeAsBytesSync([0xFF, 0xD8]);
      File('${tempDir.path}/assets/icons/home.svg')
          .writeAsStringSync('<svg></svg>');

      final scanner = AssetScanner(projectRoot: tempDir);
      final assets = await scanner.scan();

      expect(assets, hasLength(2));
      // Should be sorted: icons/ before images/
      expect(assets.first.relativePath, contains('icons'));
    });

    test('extracts correct metadata', () async {
      final assetsDir = Directory('${tempDir.path}/assets');
      assetsDir.createSync(recursive: true);
      File('${assetsDir.path}/my_image.png').writeAsBytesSync(
        List.filled(1024, 0),
      );

      final scanner = AssetScanner(projectRoot: tempDir);
      final assets = await scanner.scan();

      expect(assets, hasLength(1));
      expect(assets.first.name, equals('my_image'));
      expect(assets.first.extension, equals('png'));
      expect(assets.first.isImage, isTrue);
      expect(assets.first.fileSize, equals(1024));
    });
  });
}
