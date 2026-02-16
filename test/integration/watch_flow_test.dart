import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_assets/src/generator/code_generator.dart';
import 'package:dart_assets/src/parser/pubspec_parser.dart';
import 'package:dart_assets/src/parser/pubspec_updater.dart';

void main() {
  group('Integration: Watch Flow', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('watch_flow_test_');

      // minimal pubspec
      File('${tempDir.path}/pubspec.yaml').writeAsStringSync('''
name: test_app

flutter:
  assets: []
''');

      // assets directory
      Directory('${tempDir.path}/assets/images').createSync(recursive: true);

      // lib directory (for unused analysis)
      Directory('${tempDir.path}/lib').createSync(recursive: true);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('add file → pubspec updated → code generated', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      final updater = PubspecUpdater(pubspecFile);
      final generator = CodeGenerator(projectRoot: tempDir);

      // simulate new file added
      File('${tempDir.path}/assets/images/logo.png')
          .writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);

      // step 1: update pubspec
      await updater.addAsset('assets/images/logo.png');

      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();
      expect(assets, contains('assets/images/logo.png'));

      // step 2: generate code
      await generator.generate();

      final generatedFile = File('${tempDir.path}/lib/gen/assets.dart');
      expect(generatedFile.existsSync(), isTrue);

      final code = generatedFile.readAsStringSync();
      expect(code, contains('logo'));
      expect(code, contains('assets/images/logo.png'));
    });

    test('remove file → pubspec updated → code regenerated', () async {
      final pubspecFile = File('${tempDir.path}/pubspec.yaml');
      final updater = PubspecUpdater(pubspecFile);
      final generator = CodeGenerator(projectRoot: tempDir);

      // setup: add two files
      final logoFile = File('${tempDir.path}/assets/images/logo.png');
      logoFile.writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);
      File('${tempDir.path}/assets/images/banner.jpg')
          .writeAsBytesSync([0xFF, 0xD8, 0xFF]);

      await updater.addAsset('assets/images/logo.png');
      await updater.addAsset('assets/images/banner.jpg');
      await generator.generate();

      // simulate: remove logo
      logoFile.deleteSync();
      await updater.removeAsset('assets/images/logo.png');
      await generator.generate();

      // verify pubspec
      final parser = PubspecParser(pubspecFile);
      final assets = await parser.getAssets();
      expect(assets, isNot(contains('assets/images/logo.png')));
      expect(assets, contains('assets/images/banner.jpg'));

      // verify generated code
      final code =
          File('${tempDir.path}/lib/gen/assets.dart').readAsStringSync();
      expect(code, isNot(contains("'assets/images/logo.png'")));
      expect(code, contains('assets/images/banner.jpg'));
    });
  });
}
