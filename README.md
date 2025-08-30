# 🗺️ Pathoria - Smart Trip Planner

[![Flutter](https://img.shields.io/badge/Flutter-3.19.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

> **Google Search-Powered Travel Planning Made Simple** ✈️🌍

Pathoria is a cutting-edge Flutter application that revolutionizes travel planning by leveraging Google Search. Users can describe their dream trip in natural language, and Pathoria fetches real-time information about destinations, restaurants, hotels, and attractions using the Google Search API. Enjoy offline access, interactive chat, and more.

## ✨ Features

### 🚀 **Core MVP Features**
- **🔍 Google Search Integration** - Real-time information about restaurants, hotels, and attractions
- **💬 Real-time Chat Interface** - Refine and modify your search through conversation
- **📱 Offline Access** - Save and view search results without internet connection
- **🗺️ Maps Integration** - One-tap access to locations via Google Maps/Apple Maps
- **💰 Cost Tracking** - Monitor API usage and quotas

### 🎯 **Smart Capabilities**
- **Natural Language Search** - "7 days in Kyoto next April, solo, mid-range budget"
- **Dynamic Refinement** - Ask follow-up questions to modify your search
- **Real-time Updates** - Get current information about destinations and activities
- **Personalized Recommendations** - Search results tailored to your preferences

## 🏗️ Architecture

Pathoria follows **Clean Architecture** principles with a modern Flutter stack:

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
├──────────────────────────────────────────────────────────────┤
│  Screens │ Widgets │ Providers (Riverpod) │ Navigation       │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
├──────────────────────────────────────────────────────────────┤
│  Entities │ Use Cases │ Repository Interfaces │ Business     │
│           │           │                       │  Logic       │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
├──────────────────────────────────────────────────────────────┤
│  Models │ Repositories │ Services │ Data Sources │ External  │
│         │              │          │              │ APIs      │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                      CORE LAYER                              │
├──────────────────────────────────────────────────────────────┤
│  Config │ Utils │ Error Handling │ Constants │ Theme         │
└──────────────────────────────────────────────────────────────┘
```

### **Technology Stack**

| Layer | Technology | Purpose |
|-------|------------|---------|
| **State Management** | Riverpod 3 | Reactive state management |
| **Navigation** | GoRouter | Declarative routing |
| **Database** | Isar | Fast local storage |
| **HTTP Client** | Dio + Retrofit | API communication |
| **Authentication** | Firebase Auth | User management |
| **Search Integration** | Google Search API | Real-time info |
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
   # Edit .env with your Google Search API keys
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
# Google Search API (Required)
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
    ├── 🤖 domain/              # Business logic
    │   ├── entities/           # Business entities
    │   ├── repositories/       # Repository interfaces
    │   └── usecases/           # Business use cases
    └── 🎨 presentation/        # UI layer
        ├── providers/          # State providers
        ├── screens/            # App screens
        └── widgets/            # Reusable components
```

## 🧪 Testing Strategy

Our testing approach ensures code quality and reliability:

- **Unit Tests** (≥60% coverage) - Business logic and repositories
- **Widget Tests** - UI components and interactions
- **Integration Tests** - End-to-end user flows
- **Mock Testing** - External API dependencies

## 📚 Documentation

- [📖 API Documentation](documentation/API_DOCUMENTATION.md)
- [🏗️ Architecture Guide](documentation/ARCHITECTURE.md)
- [🤝 Contributing Guide](documentation/CONTRIBUTING.md)
- [📋 Project Analysis](documentation/PROJECT_ANALYSIS.md)

## 🚨 Known Issues

- Web search functionality requires valid Google Search API keys
- Streaming responses not yet implemented
- Maps integration requires implementation

## 🗺️ Roadmap

### **Phase 1: Core Search Integration**
- [x] Complete Google Search API integration
- [ ] Implement streaming responses
- [ ] Add maps integration

### **Phase 2: Enhanced Features**
- [ ] Offline functionality
- [ ] Performance optimization

### **Phase 3: Production Ready**
- [ ] Comprehensive testing
- [ ] Error handling
- [ ] Performance optimization

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Google** - For powerful search capabilities
- **Riverpod** - For excellent state management
- **Isar** - For fast local database
- **Community Contributors** - For making this project better

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/YKbodgam/pathoria/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YKbodgam/pathoria/discussions)
- **Wiki**: [Project Wiki](https://github.com/YKbodgam/pathoria/wiki)

---

**Made with ❤️ by the Pathoria Team**

*Transform your travel dreams into reality with search-powered planning!* ✈️🌍
