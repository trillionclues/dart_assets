import 'package:test/test.dart';
import 'package:dart_assets/src/generator/naming_converter.dart';

void main() {
  group('NamingConverter', () {
    test('converts basic names to camelCase', () {
      expect(NamingConverter.toValidIdentifier('my_image'), 'myImage');
      expect(NamingConverter.toValidIdentifier('hero-banner'), 'heroBanner');
    });

    test('handles names starting with numbers', () {
      expect(NamingConverter.toValidIdentifier('2x_icon'), '_2xIcon');
    });

    test('removes invalid characters', () {
      expect(NamingConverter.toValidIdentifier('my file @name'), 'myFileName');
    });

    test('generates unique names', () {
      final used = <String>{'myImage'};
      final unique = NamingConverter.toUniqueIdentifier('my_image', used);
      expect(unique, 'myImage2');
    });

    test('converts to PascalCase', () {
      expect(NamingConverter.toPascalCase('my_image'), 'MyImage');
    });
  });
}
