import 'dart:io';
import 'package:path/path.dart' as p;

// locate and resolving paths relative to a project root.
class PathUtils {
  static Directory? findProjectRoot(Directory startDir) {
    var dir = startDir;

    while (true) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) return dir;

      final parent = dir.parent;
      if (parent.path == dir.path) return null;
      dir = parent;
    }
  }

  static String toRelative(String absolutePath, Directory projectRoot) {
    return p.relative(absolutePath, from: projectRoot.path);
  }
}
