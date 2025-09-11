# Contributing to Pathoria - Smart Trip Planner

Thank you for your interest in contributing to Pathoria! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19.0 or higher
- Dart SDK 3.3.0 or higher
- Git
- IDE (VS Code or Android Studio recommended)

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/YKbodgam/Smart-Trip-Planner`
3. Install dependencies: `flutter pub get`
4. Generate code: `dart run build_runner build`
5. Run tests: `flutter test`

## 📋 Code Standards

### Architecture Guidelines
- Follow Clean Architecture principles
- Maintain separation of concerns (data → domain → presentation)
- Use dependency injection with Riverpod
- Keep business logic in use cases

### Coding Style
- Follow Dart/Flutter conventions
- Use `flutter analyze` and fix all warnings
- Format code with `dart format`
- Use meaningful variable and function names
- Add documentation for public APIs

### File Organization
```
lib/
├── core/           # Shared utilities and configuration
├── data/           # Data layer (models, repositories, services)
├── domain/         # Business logic (entities, use cases)
└── presentation/   # UI layer (screens, widgets, providers)
```

### Naming Conventions
- **Files**: snake_case (e.g., `user_profile_screen.dart`)
- **Classes**: PascalCase (e.g., `UserProfileScreen`)
- **Variables/Functions**: camelCase (e.g., `getUserProfile`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `API_BASE_URL`)

## 🧪 Testing Requirements

### Test Coverage
- Maintain >60% test coverage
- Write unit tests for business logic
- Add widget tests for UI components
- Include integration tests for critical flows

### Test Structure
```
test/
├── unit/           # Unit tests for repositories, use cases
├── widget/         # Widget tests for UI components
└── integration/    # End-to-end tests
```

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/repositories/user_repository_test.dart
```

## 🎨 UI/UX Guidelines

### Design System
- Use Material Design 3 components
- Follow the established color scheme
- Maintain consistent spacing using ScreenUtil
- Ensure responsive design across all screen sizes

### Accessibility
- Add semantic labels for screen readers
- Ensure sufficient color contrast
- Support keyboard navigation
- Test with accessibility tools

## 📝 Pull Request Process

### Before Submitting
1. Ensure all tests pass
2. Run `flutter analyze` with no issues
3. Format code with `dart format`
4. Update documentation if needed
5. Add/update tests for new features

### PR Guidelines
- Use descriptive titles and descriptions
- Reference related issues
- Include screenshots for UI changes
- Keep PRs focused and atomic
- Request reviews from maintainers

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests pass
- [ ] Documentation updated
```

## 🐛 Bug Reports

### Before Reporting
- Search existing issues
- Reproduce the bug
- Test on latest version

### Bug Report Template
```markdown
**Describe the bug**
Clear description of the issue

**To Reproduce**
Steps to reproduce the behavior

**Expected behavior**
What you expected to happen

**Screenshots**
Add screenshots if applicable

**Environment:**
- Device: [e.g. iPhone 12, Pixel 5]
- OS: [e.g. iOS 15.0, Android 12]
- App Version: [e.g. 1.0.0]
```

## 💡 Feature Requests

### Feature Request Template
```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
Clear description of desired feature

**Describe alternatives you've considered**
Alternative solutions considered

**Additional context**
Any other context or screenshots
```

## 🔄 Development Workflow

### Branch Naming
- `feature/feature-name` - New features
- `bugfix/bug-description` - Bug fixes
- `hotfix/critical-fix` - Critical fixes
- `docs/documentation-update` - Documentation

### Commit Messages
Follow conventional commits:
- `feat: add user authentication`
- `fix: resolve chat message display issue`
- `docs: update API documentation`
- `test: add unit tests for user repository`

## 🧑‍💻 Clean Architecture Compliance

### Architecture Rules

**Clean Architecture Compliance**
- ✅ **Presentation Layer** can ONLY depend on Domain Layer
- ✅ **Data Layer** can ONLY depend on Domain Layer  
- ✅ **Domain Layer** must have NO external dependencies
- ✅ **Core Layer** is shared across all layers

**Dependency Injection**
- Use Riverpod providers for all dependencies
- Never create instances directly with `new` keyword
- All services must be injectable and testable
- Follow the provider hierarchy pattern:

```dart
// ✅ CORRECT: Provider hierarchy
final repositoryProvider = Provider<Repository>((ref) => RepositoryImpl());
final useCaseProvider = Provider<UseCase>((ref) => 
  UseCase(ref.read(repositoryProvider)));
final viewModelProvider = StateNotifierProvider<ViewModel, State>((ref) => 
  ViewModel(ref.read(useCaseProvider)));

// ❌ WRONG: Direct instantiation
final viewModel = ViewModel(RepositoryImpl()); // Don't do this!
```

## 🚨 Code Review Checklist

### Before Submitting PR
- [ ] All tests pass (`flutter test`)
- [ ] Code analysis clean (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] No hardcoded values
- [ ] Proper error handling
- [ ] Accessibility features added
- [ ] Documentation updated
- [ ] Performance considered

### During Code Review
- [ ] Architecture principles followed
- [ ] Naming conventions correct
- [ ] Error handling appropriate
- [ ] Tests comprehensive
- [ ] Security considerations addressed
- [ ] Performance impact assessed
- [ ] UI/UX guidelines followed

## 📊 Quality Metrics

### Code Quality Targets
- **Test Coverage**: ≥ 60%
- **Code Duplication**: < 5%
- **Complexity**: Cyclomatic complexity < 10
- **Documentation**: 100% public API documented
- **Performance**: App startup < 3 seconds

### Monitoring Tools
- `flutter analyze` - Code analysis
- `flutter test --coverage` - Test coverage
- `dart format .` - Code formatting
- `flutter build` - Build verification

## 🔄 Git & Version Control Rules

### Branch Naming
```bash
# ✅ CORRECT: Descriptive branch names
git checkout -b feature/ai-streaming-responses
git checkout -b bugfix/chat-message-display
git checkout -b hotfix/critical-api-fix
git checkout -b docs/update-readme

# ❌ WRONG: Unclear branch names
git checkout -b feature1
git checkout -b fix
git checkout -b new
```

### Commit Messages
```bash
# ✅ CORRECT: Conventional commit format
git commit -m "feat: implement streaming AI responses"
git commit -m "fix: resolve chat message display issue"
git commit -m "docs: update API documentation"
git commit -m "test: add unit tests for user repository"
git commit -m "refactor: improve error handling in AI service"

# ❌ WRONG: Unclear commit messages
git commit -m "fixed stuff"
git commit -m "update"
git commit -m "changes"
```

## 📚 Code Documentation

### Code Documentation
```dart
/// A service that handles AI-powered itinerary generation.
/// 
/// This service integrates with OpenAI's GPT models to create
/// personalized travel itineraries based on user input.
/// 
/// Example usage:
/// ```dart
/// final aiService = AIService();
/// final itinerary = await aiService.generateItinerary(
///   prompt: '7 days in Kyoto next April',
/// );
/// ```
class AIService {
  /// Generates a travel itinerary based on the provided prompt.
  /// 
  /// [prompt] - Natural language description of the desired trip
  /// [chatHistory] - Optional chat history for context
  /// [existingItinerary] - Optional existing itinerary to refine
  /// 
  /// Returns an [Either] containing either a [Failure] or [Itinerary].
  /// 
  /// Throws [NetworkException] when network is unavailable.
  Future<Either<Failure, Itinerary>> generateItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async {
    // Implementation
  }
}
```

### README Updates
- Update README.md for any new features
- Keep installation instructions current
- Document breaking changes
- Update project status and roadmap

## 📈 Enforcement

### Automated Checks
- GitHub Actions for CI/CD
- Pre-commit hooks for code quality
- Automated testing on all PRs
- Code coverage reporting

### Manual Reviews
- All PRs require review
- Architecture decisions need approval
- Breaking changes require team discussion
- Performance changes need benchmarking

## 📚 Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Tools
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Very Good CLI](https://cli.vgv.dev)

## 🤝 Community

- Be respectful and inclusive
- Help others learn and grow
- Share knowledge and best practices
- Follow the code of conduct

## 📞 Getting Help

- Create an issue for bugs or questions
- Join discussions in existing issues
- Check the documentation first
- Be patient and provide context

Thank you for contributing to Pathoria! 🌍✈️
