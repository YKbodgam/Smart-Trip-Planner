# 🗺️ Pathoria - Smart Trip Planner

[![Flutter](https://img.shields.io/badge/Flutter-3.19.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

> **AI-Powered Travel Planning Made Simple** ✈️🌍

Pathoria is a cutting-edge Flutter application that revolutionizes travel planning by leveraging artificial intelligence. Users can describe their dream trip in natural language, and our AI generates personalized, day-by-day itineraries with real-time information, offline access, and interactive chat refinement.

## ✨ Features

### 🚀 **Core MVP Features**
- **🤖 AI-Powered Itinerary Generation** - Create detailed travel plans using natural language
- **💬 Real-time Chat Interface** - Refine and modify itineraries through conversation
- **📱 Offline Access** - Save and view itineraries without internet connection
- **🔍 Web Search Integration** - Real-time information about restaurants, hotels, and attractions
- **🗺️ Maps Integration** - One-tap access to locations via Google Maps/Apple Maps
- **💰 Cost Tracking** - Monitor token usage and API costs

### 🎯 **Smart Capabilities**
- **Natural Language Processing** - "7 days in Kyoto next April, solo, mid-range budget"
- **Dynamic Refinement** - Ask follow-up questions to modify existing plans
- **Real-time Updates** - Get current information about destinations and activities
- **Personalized Recommendations** - AI learns from your preferences and travel style

## 🏗️ Architecture

Pathoria follows **Clean Architecture** principles with a modern Flutter stack:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│  Screens │ Widgets │ Providers (Riverpod) │ Navigation      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  Entities │ Use Cases │ Repository Interfaces │ Business    │
│           │           │                       │  Logic      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  Models │ Repositories │ Services │ Data Sources │ External │
│         │              │          │              │ APIs     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CORE LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  Config │ Utils │ Error Handling │ Constants │ Theme        │
└─────────────────────────────────────────────────────────────┘
```

### **Technology Stack**

| Layer | Technology | Purpose |
|-------|------------|---------|
| **State Management** | Riverpod 3 | Reactive state management |
| **Navigation** | GoRouter | Declarative routing |
| **Database** | Isar | Fast local storage |
| **HTTP Client** | Dio + Retrofit | API communication |
| **Authentication** | Firebase Auth | User management |
| **AI Integration** | OpenAI GPT-4 | Itinerary generation |
| **Maps** | URL Launcher | External map apps |

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK 3.19.0 or higher
- Dart SDK 3.3.0 or higher
- Android Studio / VS Code
- Git

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/YKbodgam/pathoria.git
   cd pathoria
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

4. **Generate code**
   ```bash
   dart run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### **Environment Setup**

Create a `.env` file in the root directory:

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_BASE_URL=https://api.openai.com/v1

# Google Search API (Optional)
GOOGLE_SEARCH_API_KEY=your_google_search_api_key
GOOGLE_SEARCH_ENGINE_ID=your_search_engine_id

# Firebase Configuration
FIREBASE_PROJECT_ID=your_project_id
```

## 📱 App Structure

```
lib/
├── 📱 app.dart                 # Main app configuration
├── 🚀 main.dart                # App entry point
└── src/
    ├── 🏗️ core/                # Shared utilities & configuration
    │   ├── config/             # App configuration
    │   ├── constants/          # App constants
    │   ├── error/              # Error handling
    │   ├── router/             # Navigation
    │   ├── theme/              # UI themes
    │   └── utils/              # Helper functions
    ├── 📊 data/                # Data layer
    │   ├── models/             # Data models
    │   ├── repositories/       # Repository implementations
    │   └── services/           # External services
    ├── 🧠 domain/              # Business logic
    │   ├── entities/           # Business entities
    │   ├── repositories/       # Repository interfaces
    │   └── usecases/           # Business use cases
    └── 🎨 presentation/        # UI layer
        ├── providers/          # State providers
        ├── screens/            # App screens
        └── widgets/            # Reusable components
```

## 🔧 Development

### **Code Generation**
```bash
# Generate all code
dart run build_runner build

# Watch for changes
dart run build_runner watch

# Clean generated files
dart run build_runner clean
```

### **Testing**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/repositories/user_repository_test.dart
```

### **Code Quality**
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Fix linting issues
dart fix --apply
```

## 🧪 Testing Strategy

Our testing approach ensures code quality and reliability:

- **Unit Tests** (≥60% coverage) - Business logic and repositories
- **Widget Tests** - UI components and interactions
- **Integration Tests** - End-to-end user flows
- **Mock Testing** - External API dependencies

## 📊 Project Status

| Feature | Status | Progress |
|---------|--------|----------|
| **App Structure** | ✅ Complete | 100% |
| **UI Components** | ✅ Complete | 100% |
| **Navigation** | ✅ Complete | 100% |
| **Database** | ✅ Complete | 100% |
| **AI Integration** | 🔄 In Progress | 60% |
| **Chat Interface** | 🔄 In Progress | 70% |
| **Web Search** | ❌ Not Started | 0% |
| **Maps Integration** | ❌ Not Started | 0% |
| **Testing** | ❌ Not Started | 0% |

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and contribute to the project.

### **Quick Start for Contributors**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

### **Development Workflow**
- Follow [Conventional Commits](https://conventionalcommits.org/)
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

## 📚 Documentation

- [📖 API Documentation](documentation/API_DOCUMENTATION.md)
- [🏗️ Architecture Guide](documentation/ARCHITECTURE.md)
- [🤝 Contributing Guide](documentation/CONTRIBUTING.md)
- [📋 Project Analysis](documentation/PROJECT_ANALYSIS.md)

## 🚨 Known Issues

- AI service integration needs completion
- Streaming responses not yet implemented
- Web search functionality pending
- Maps integration requires implementation

## 🔮 Roadmap

### **Phase 1: Core AI Integration** (Weeks 1-2)
- [ ] Complete OpenAI API integration
- [ ] Implement streaming responses
- [ ] Add web search functionality

### **Phase 2: Enhanced Features** (Weeks 3-4)
- [ ] Maps integration
- [ ] Offline functionality
- [ ] Performance optimization

### **Phase 3: Production Ready** (Weeks 5-6)
- [ ] Comprehensive testing
- [ ] Error handling
- [ ] Performance optimization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **OpenAI** - For powerful AI capabilities
- **Riverpod** - For excellent state management
- **Isar** - For fast local database
- **Community Contributors** - For making this project better

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/YKbodgam/pathoria/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YKbodgam/pathoria/discussions)
- **Wiki**: [Project Wiki](https://github.com/YKbodgam/pathoria/wiki)

<!-- ## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=YKbodgam/pathoria&type=Date)](https://star-history.com/#YKbodgam/pathoria&Date) -->

---

**Made with ❤️ by the Pathoria Team**

*Transform your travel dreams into reality with AI-powered planning!* ✈️🌍
