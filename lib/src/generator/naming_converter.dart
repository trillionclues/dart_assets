// Converts file names to valid Dart identifiers

class NamingConverter {
  static String toValidIdentifier(String name) {
    name = name.split('.').first;
    name = name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    name = _toCamelCase(name);

    if (name.isNotEmpty && RegExp(r'^\d').hasMatch(name)) {
      name = '_$name';
    }

    return name;
  }

  static String toUniqueIdentifier(String baseName, Set<String> usedNames) {
    var name = toValidIdentifier(baseName);

    if (usedNames.contains(name)) {
      var counter = 2;
      while (usedNames.contains('$name$counter')) {
        counter++;
      }
      name = '$name$counter';
    }

    return name;
  }

  static String toPascalCase(String input) {
    final camelCase = _toCamelCase(input);
    if (camelCase.isEmpty) return camelCase;
    return camelCase[0].toUpperCase() + camelCase.substring(1);
  }

  static String _toCamelCase(String input) {
    final parts = input.split(RegExp(r'[-_\s]+'));
    if (parts.isEmpty) return input;

    final first = parts.first.toLowerCase();
    final rest = parts.skip(1).map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    });

    return [first, ...rest].join();
  }
}
