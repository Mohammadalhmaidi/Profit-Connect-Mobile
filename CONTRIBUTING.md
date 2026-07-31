# Contributing to Profit Connect Mobile

Thank you for your interest in contributing! This guide will help you get started.

## 📋 Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/profit-connect-mobile.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `make test`
6. Run analysis: `make analyze`
7. Commit your changes: `git commit -m 'feat: add amazing feature'`
8. Push to your fork: `git push origin feature/your-feature-name`
9. Open a Pull Request

## 📝 Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat(auth): add biometric login support
fix(chat): resolve message ordering issue
docs: update API documentation
refactor(feed): extract post card widget
```

## 🧪 Testing Requirements

- All new features must include unit tests (target: ≥80% coverage)
- Widget tests for new UI components
- Integration tests for critical user flows
- Run `make test` before submitting

## 📏 Code Style

- Follow `analysis_options.yaml` rules
- Run `make format` before committing
- Use `flutter analyze --fatal-infos` to check for issues
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines

## 🏗️ Architecture Guidelines

- Follow Clean Architecture (Domain → Data → Presentation)
- Use BLoC/Cubit for state management
- Keep widgets small and focused
- Dependency injection via GetIt
- Repository pattern for data access

## 📝 Pull Request Template

When opening a PR, please include:

1. **Description**: What does this PR do?
2. **Type**: feat/fix/docs/refactor/test/chore
3. **Testing**: How did you test this?
4. **Screenshots**: For UI changes
5. **Checklist**:
   - [ ] Tests pass
   - [ ] Analysis passes
   - [ ] Code formatted
   - [ ] Documentation updated

## 🔍 Code Review Process

1. All PRs require at least 1 approval
2. CI must pass (analysis, tests, build)
3. Address all review comments
4. Squash commits before merge

## 📞 Getting Help

- Open an issue for bugs
- Start a discussion for questions
- Check existing issues/PRs first

Thank you for contributing! 🎉