import 'package:test/test.dart';
import 'package:dart_assets/src/watcher/filters.dart';

void main() {
  group('FileFilter', () {
    test('identifies image files', () {
      expect(FileFilter.isImage('assets/images/logo.png'), isTrue);
      expect(FileFilter.isImage('assets/images/photo.jpg'), isTrue);
      expect(FileFilter.isImage('assets/images/photo.JPEG'), isTrue);
      expect(FileFilter.isImage('assets/images/icon.svg'), isTrue);
      expect(FileFilter.isImage('assets/images/anim.gif'), isTrue);
      expect(FileFilter.isImage('assets/images/hero.webp'), isTrue);
    });

    test('identifies font files', () {
      expect(FileFilter.isFont('assets/fonts/Roboto.ttf'), isTrue);
      expect(FileFilter.isFont('assets/fonts/Open.otf'), isTrue);
      expect(FileFilter.isFont('assets/fonts/web.woff2'), isTrue);
    });

    test('identifies data files', () {
      expect(FileFilter.isData('assets/data/config.json'), isTrue);
      expect(FileFilter.isData('assets/data/schema.yaml'), isTrue);
      expect(FileFilter.isData('assets/data/table.csv'), isTrue);
    });

    test('rejects non-asset files', () {
      expect(FileFilter.isAsset('lib/main.dart'), isFalse);
      expect(FileFilter.isAsset('README.md'), isFalse);
      expect(FileFilter.isAsset('Makefile'), isFalse);
    });

    test('isAsset includes all types', () {
      expect(FileFilter.isAsset('a/b/c.png'), isTrue);
      expect(FileFilter.isAsset('a/b/c.ttf'), isTrue);
      expect(FileFilter.isAsset('a/b/c.json'), isTrue);
      expect(FileFilter.isAsset('a/b/c.mp4'), isTrue);
    });
  });

  group('PatternFilter', () {
    test('ignores hidden files', () {
      expect(PatternFilter.shouldIgnore('/project/.hidden_file'), isTrue);
    });

    test('ignores DS_Store', () {
      expect(PatternFilter.shouldIgnore('/assets/.DS_Store'), isTrue);
    });

    test('ignores tmp files', () {
      expect(PatternFilter.shouldIgnore('/assets/file.tmp'), isTrue);
    });

    test('ignores git directory', () {
      expect(PatternFilter.shouldIgnore('/project/.git/HEAD'), isTrue);
    });

    test('allows normal asset files', () {
      expect(PatternFilter.shouldIgnore('/assets/images/logo.png'), isFalse);
      expect(PatternFilter.shouldIgnore('/assets/fonts/Roboto.ttf'), isFalse);
    });
  });
}
