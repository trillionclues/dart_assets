# GIT WORKFLOW & CONVENTIONS

## Branch Strategy

### Main Branches
```
main
  ↓
develop
  ↓
feature/* or fix/*
```

**Branch Purposes:**
- `main` - Production-ready code, pub.dev releases
- `develop` - Integration branch
- `feature/*` - New features
- `fix/*` - Bug fixes
- `hotfix/*` - Critical production fixes
- `release/*` - Release preparation

---

## Branch Naming

### Format
```
<type>/<short-description>
```

### Types

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation only
- `refactor/` - Code refactoring
- `test/` - Adding tests
- `chore/` - Maintenance

### Examples
```bash
feature/watch-mode
feature/webp-conversion
fix/pubspec-parsing
fix/naming-conflicts
docs/update-readme
refactor/code-generator
test/integration-tests
chore/update-dependencies
```

---

## Commit Messages

### Format (Conventional Commits)
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting
- `refactor` - Code refactoring
- `perf` - Performance
- `test` - Tests
- `chore` - Maintenance
- `ci` - CI/CD

### Scopes

- `cli` - CLI commands
- `watcher` - File watcher
- `parser` - Pubspec parser
- `generator` - Code generator
- `optimizer` - Image optimizer
- `analyzer` - Usage analyzer

### Examples

**Good:**
```
feat(watcher): add debouncing for file changes

- Implement Debouncer class with configurable duration
- Add per-file debouncing to prevent duplicate processing
- Update tests

Closes #42
```
```
fix(parser): preserve comments in pubspec.yaml

Previously, yaml_edit was not preserving comments.
Now uses proper YAML preservation strategy.

Fixes #58
```
```
docs(readme): add installation instructions

Add npm and pub global activate examples.
```

**Bad:**
```
Update stuff
```
```
Fix bug
```
```
WIP
```

---

## Pull Request Process

### 1. Create Branch
```bash
git checkout develop
git pull origin develop
git checkout -b feature/watch-mode
```

### 2. Make Changes
```bash
# Make changes
git add .
git commit -m "feat(watcher): implement file watching"
```

### 3. Push Branch
```bash
git push origin feature/watch-mode
```

### 4. Create PR

**PR Template:**

**`.github/PULL_REQUEST_TEMPLATE.md`:**
```markdown
## Description

Brief description of changes.

## Type of Change

- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added
- [ ] All tests passing

## Related Issues

Closes #123

## Screenshots (if applicable)

[Add screenshots]
```

---

## Release Process

### Version Numbering (Semantic Versioning)
```
MAJOR.MINOR.PATCH

1.2.3
│ │ │
│ │ └─ Patch: Bug fixes
│ └─── Minor: New features (backward compatible)
└───── Major: Breaking changes
```

### Release Workflow

**1. Create Release Branch**
```bash
git checkout develop
git pull origin develop
git checkout -b release/1.2.0
```

**2. Update Version**

**pubspec.yaml:**
```yaml
version: 1.2.0
```

**3. Update CHANGELOG.md**
```markdown
## [1.2.0] - 2025-02-14

### Added
- Watch mode for automatic asset management
- WebP conversion support
- Image optimization

### Fixed
- Pubspec comment preservation
- Naming conflict resolution

### Changed
- Improved error messages
- Better CLI output
```

**4. Commit Changes**
```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): prepare 1.2.0"
git push origin release/1.2.0
```

**5. Create PR to Main**
```bash
# Create PR: release/1.2.0 → main
# After approval and CI passes, merge
```

**6. Tag Release**
```bash
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release 1.2.0"
git push origin v1.2.0
```

**7. Merge Back to Develop**
```bash
git checkout develop
git merge --no-ff main
git push origin develop
```

**8. Delete Release Branch**
```bash
git branch -d release/1.2.0
git push origin --delete release/1.2.0
```

---

## Hotfix Process

For critical production bugs:

**1. Create Hotfix Branch**
```bash
git checkout main
git checkout -b hotfix/critical-parser-bug
```

**2. Fix and Test**
```bash
# Make fix
git commit -m "fix(parser): critical YAML parsing bug"
```

**3. Update Version (Patch)**
```bash
# pubspec.yaml: 1.2.0 → 1.2.1
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): 1.2.1 hotfix"
```

**4. Merge to Main**
```bash
git checkout main
git merge --no-ff hotfix/critical-parser-bug
git tag -a v1.2.1 -m "Hotfix 1.2.1"
git push origin main --tags
```

**5. Merge to Develop**
```bash
git checkout develop
git merge --no-ff hotfix/critical-parser-bug
git push origin develop
```

---

## Git Hooks

### Pre-Commit Hook

**`.git/hooks/pre-commit`:**
```bash
#!/bin/bash

# Run formatter
dart format .

# Run analyzer
dart analyze

if [ $? -ne 0 ]; then
    echo "Analyzer found issues. Please fix before committing."
    exit 1
fi

# Run tests
dart test

if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix before committing."
    exit 1
fi

echo "All checks passed!"
```

### Using Husky (Alternative)
```bash
# Install Husky
dart pub add --dev husky

# Create hooks
dart run husky install
```

**.husky/pre-commit:**
```bash
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

dart format .
dart analyze
dart test
```

---

## .gitignore
```gitignore
# Flutter/Dart
.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies

# Generated files
lib/gen/
*.g.dart

# IDE
.idea/
.vscode/
*.iml
*.ipr
*.iws

# macOS
.DS_Store

# Coverage
coverage/

# Test
.test_coverage.dart

# Temp
*.log
*.tmp
.temp/
```

---

## Best Practices

### Commit Frequency
- Commit often (small, logical changes)
- Each commit should be functional
- Don't commit broken code
- Don't commit "WIP" to shared branches

### Branch Hygiene
- Keep branches short-lived (<1 week)
- Rebase frequently from develop
- Delete after merge
- Don't work directly on develop/main

### Code Review
- Review within 24 hours
- Be constructive
- Test changes locally
- Don't approve without reviewing

---

## Troubleshooting

### Merge Conflicts
```bash
# Update your branch
git checkout feature/my-feature
git fetch origin
git rebase origin/develop

# Resolve conflicts
# Edit conflicted files
git add <resolved-files>
git rebase --continue

# Force push (if already pushed)
git push origin feature/my-feature --force-with-lease
```

### Undo Last Commit
```bash
# Keep changes
git reset --soft HEAD~1

# Discard changes
git reset --hard HEAD~1
```

### Rewrite Commit Message
```bash
# Last commit
git commit --amend -m "New message"

# Older commits
git rebase -i HEAD~3
# Mark 'reword' for commits to change
```