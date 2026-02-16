## Description

Brief description of what this PR does.

## Type of Change

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would break existing behavior)
- [ ] 📝 Documentation update
- [ ] ♻️ Refactor (no functional changes)
- [ ] 🧪 Test update

## Testing

- [ ] Unit tests pass (`dart test`)
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows the project's style guidelines (`dart format .`)
- [ ] Self-review of code completed
- [ ] Comments added for complex logic
- [ ] Documentation updated (if applicable)
- [ ] No new analyzer warnings (`dart analyze`)
- [ ] Tests added for new functionality
- [ ] All existing tests still pass

## Related Issues

Closes #

## Screenshots (if applicable)

<!-- to publish to pub.dev -->
<!-- id-token: write for OIDC-based authentication -->
```bash
# 1. Update version in pubspec.yaml
# 2. Update CHANGELOG.md
# 3. Commit and push
git add -A && git commit -m "chore: release v0.2.0"
git tag v0.2.0
git push origin main --tags
```