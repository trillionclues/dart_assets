// Represents a file system event for an asset.
enum FileEventType { add, modify, remove }

class FileEvent {
  final FileEventType type;
  final String path;
  final DateTime timestamp;

  FileEvent({
    required this.type,
    required this.path,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'FileEvent($type, $path)';
}
