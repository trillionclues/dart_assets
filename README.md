<p align="center">
  <h1 align="center">dart_assets</h1>
  <p align="center">
    <strong>Zero-friction asset management for Flutter developers</strong>
  </p>
  <p align="center">
    <a href="https://pub.dev/packages/dart_assets"><img src="https://img.shields.io/pub/v/dart_assets.svg" alt="pub package"></a>
    <a href="https://github.com/trillionclues/dart_assets/actions/workflows/ci.yml"><img src="https://github.com/trillionclues/dart_assets/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
    <a href="https://codecov.io/gh/trillionclues/dart_assets"><img src="https://codecov.io/gh/trillionclues/dart_assets/branch/main/graph/badge.svg" alt="Coverage"></a>
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT"></a>
    <a href="https://pub.dev/packages/dart_assets/score"><img src="https://img.shields.io/pub/points/dart_assets" alt="pub points"></a>
  </p>
</p>

---

Eliminate the manual, error-prone process of managing Flutter assets. **dart_assets** watches your assets folder, auto-updates `pubspec.yaml`, generates type-safe Dart code, optimizes images, and catches issues before they reach production — all from a single command.

## ✨ Features

| Feature | Description |
|---|---|
| 🔄 **Watch Mode** | Automatically detects file changes and updates your project in real time |
| 📄 **Pubspec Sync** | Adds and removes assets from `pubspec.yaml` as files change |
| 🛡️ **Type-Safe Code Gen** | Generates a Dart class with `const` references — no more string typos |
| 🖼️ **Image Optimization** | Compress PNGs, JPEGs, and convert to WebP for smaller app bundles |
| 🔍 **Unused Asset Detection** | Find dead assets wasting storage in your project |
| 🩺 **Project Doctor** | Validate your asset setup and catch misconfigurations early |

## 🚀 Quick Start

### Installation

```bash
# Activate globally
dart pub global activate dart_assets

# Or add as a dev dependency
dart pub add --dev dart_assets
```

### Start Watching

```bash
cd your_flutter_project
dart_assets watch
```

That's it. Drop files into `assets/`, and everything updates automatically:

```
👀 Watching: /your_flutter_project/assets/

[14:32:15] + assets/images/logo.png
  > Updated pubspec.yaml
  > Regenerated assets.dart

# Flutter hot reload picks up the change instantly!
```

## 📖 Usage

### Commands

| Command | Description |
|---|---|
| `dart_assets watch` | Watch assets folder and auto-update on changes |
| `dart_assets gen` | One-time code generation for asset references |
| `dart_assets optimize` | Compress and optimize images for production |
| `dart_assets unused` | Detect assets not referenced anywhere in code |
| `dart_assets clean` | Remove unused assets from the project |
| `dart_assets check` | Validate asset setup (CI-friendly) |
| `dart_assets doctor` | Diagnose common asset configuration issues |

### Watch Mode

Runs alongside `flutter run` for a seamless development workflow.

### Code Generation

**Without dart_assets** — runtime errors from typos:
```dart
// Typo & crashes only caught at runtime
Image.asset('assets/images/loggo.png');

Image.asset('assets/images/???');
```

**With dart_assets** — compile-time safety:
```dart
// Compile-time checked & IDE autocomplete
Image.asset(Assets.logo);

Image.asset(Assets.);
```

**Generated code:**
```dart
// lib/gen/assets.dart — GENERATED, DO NOT MODIFY

class Assets {
  Assets._();

  static const String logo = 'assets/images/logo.png';
  static const String background = 'assets/images/background.jpg';
  static const String iconHome = 'assets/icons/home.svg';

  static const String robotoRegular = 'assets/fonts/Roboto-Regular.ttf';
  static const String robotoBold = 'assets/fonts/Roboto-Bold.ttf';

  // All assets
  static const List<String> all = [
    logo,
    background,
    iconHome,
    robotoRegular,
    robotoBold,
  ];
}
```

### Image Optimization

```bash
# Preview what would be optimized (dry run)
dart_assets optimize --dry-run

# Optimize with WebP conversion
dart_assets optimize --webp

# Set JPEG quality
dart_assets optimize --quality 85
```

### Unused Asset Detection

```bash
dart_assets unused
```

### CI Integration

Add asset validation to your CI pipeline:

```bash
dart_assets check
```

Returns a non-zero exit code if:
- Assets listed in `pubspec.yaml` don't exist on disk
- Files in `assets/` are missing from `pubspec.yaml`
- Images exceed size limits
- Generated code is out of date

## ⚙️ Configuration

Create a `dart_assets.yaml` (optional) in your project root for custom settings:

```yaml
watch:
  debounce_ms: 500            # duration for rapid file changes

generate:
  output: lib/gen/assets.dart  # Output path for generated code
  class_name: Assets           # Name of the generated class

optimize:
  max_file_size_kb: 500        # Warn on files exceeding this size
  jpeg_quality: 85             # Default JPEG quality (0–100)
  webp: false                  # Convert to WebP by default

analyze:
  exclude:                     # Patterns to exclude from analysis
    - "assets/raw/**"
```

## 🤝 Contributing

Contributions are welcome! Please read the guidelines below before submitting a pull request.

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/): `feat(watcher): add debouncing`
4. **Push** to your branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request against `develop`

### Development Setup

```bash
git clone https://github.com/trillionclues/dart_assets.git
cd dart_assets

dart pub get

# Run locally
dart run bin/dart_assets.dart watch

dart test

# Format & analyze
dart format .
dart analyze
```

See the [docs/](docs/) folder for detailed architecture and development guides.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ for the Flutter community
</p>
