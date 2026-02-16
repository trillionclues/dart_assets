<p align="center">
  <h1 align="center">dart_assets</h1>
  <!-- <p align="center">
    <img src="https://raw.githubusercontent.com/trillionclues/dart_assets/main/assets/logo.png" alt="dart_assets logo" width="200" height="200">
  </p> -->
  <p align="center">
    <strong>Zero-friction asset management for Flutter developers</strong>
  </p>
  <p align="center">
    <a href="https://pub.dev/packages/dart_assets"><img src="https://img.shields.io/pub/v/dart_assets.svg" alt="pub package"></a>
    <a href="https://github.com/trillionclues/dart_assets/actions/workflows/ci.yml"><img src="https://github.com/trillionclues/dart_assets/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
    <a href="https://codecov.io/gh/trillionclues/dart_assets"><img src="https://codecov.io/gh/trillionclues/dart_assets/branch/main/graph/badge.svg" alt="Coverage"></a>  </p>
</p>

## Quick Start

### Installation

```bash
# Activate globally
dart pub global activate dart_assets

# Or add as a dev dependency
dart pub add --dev dart_assets
```

#### Start Watching

```bash
cd your_flutter_project
dart_assets watch
```

That's it. Drop files into `assets/`, and everything updates automatically and flutter hot reload picks up the change instantly!

#### Commands

| Command | Description |
|---|---|
| `dart_assets watch` | Watch assets folder and auto-update on changes |
| `dart_assets gen` | One-time code generation for asset references |
| `dart_assets optimize` | Compress and optimize images for production |
| `dart_assets unused` | Detect assets not referenced anywhere in code |
| `dart_assets clean` | Remove unused assets from the project |
| `dart_assets check` | Validate asset setup (CI-friendly) |
| `dart_assets doctor` | Diagnose common asset configuration issues |

#### Configuration

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

#### Contributing

Contributions are welcome! Please read the guidelines below before submitting a pull request.
See the [docs/](docs/) folder for detailed architecture and development guides.

#### License
MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ for the Flutter community
</p>
