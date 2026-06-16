# Contributing to Pépito Updates

## How to Contribute

1. **Fork** the repository
2. **Branch** from `main` (see branch naming below)
3. **Commit** your changes using conventional commit messages
4. **Push** to your fork and open a **Pull Request** against `main`

## Branch Naming

Use the following prefixes:

| Prefix | Purpose |
|--------|---------|
| `feat/description` | New features |
| `fix/description` | Bug fixes |
| `refactor/description` | Code refactoring |
| `chore/description` | Maintenance, config changes |
| `docs/description` | Documentation updates |
| `test/description` | Adding or fixing tests |

Example: `feat/dark-mode-toggle`, `fix/supabase-timeout`

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add dark mode toggle
fix: handle null status from API
refactor: extract activity chart widget
chore: upgrade supabase_flutter to 2.5.6
docs: update setup instructions
test: add provider unit tests
```

## Code Style

- Follow **Dart** conventions — run `dart format` before committing
- Use **Riverpod v2+ patterns**:
  - Prefer `NotifierProvider` / `AsyncNotifierProvider` over `StateNotifierProvider`
  - Use `ref.watch` for reactive reads, `ref.read` for one-time reads
  - Keep providers focused and composable
- Prefer `const` constructors wherever possible
- Use named parameters for widget constructors
- Keep functions small and single-purpose
- Import style: group Dart/Flutter SDK, then external packages, then project imports
- Use the project's `analysis_options.yaml` — it enforces the lint rules

## Pull Request Requirements

Before submitting, ensure:

- [ ] `flutter analyze` passes with **zero issues**
- [ ] `flutter test` passes (all existing tests)
- [ ] New features include unit/widget tests
- [ ] No hardcoded secrets, tokens, or credentials
- [ ] `const` constructors used where possible
- [ ] Code follows the project's existing patterns and conventions
- [ ] Screenshots or screen recordings attached for UI changes (if applicable)

## Review Process

1. Maintainers review the PR within 2–3 business days
2. CI must pass (analyze + test)
3. Address any review comments
4. Once approved, a maintainer will squash-merge your PR

## Environment Variables

Never commit real credentials. Use `--dart-define` or `.env` files (listed in `.gitignore`). For CI, use GitHub Secrets.

## Getting Help

Open an issue for questions or discussions before making large changes.
