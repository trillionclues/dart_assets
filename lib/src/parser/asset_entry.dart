class AssetEntry {
  final String path;

  bool get isDirectory => path.endsWith('/');

  const AssetEntry({required this.path});

  @override
  String toString() => path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetEntry &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
