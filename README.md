# 🗺️ Pathoria - AI-Powered Smart Trip Planner

<div align="center">
  <img src="assets/images/identification/app_icon_foreground.png" alt="Pathoria App Banner" width="200"/>
</div>

<div align="center">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.19.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://docs.flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![AI Powered](https://img.shields.io/badge/AI_Powered-8A2BE2?style=for-the-badge&logo=ai&logoColor=white)](https://developers.google.com/custom-search)
  [![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
  
</div>

## 📱 App Showcase

<div align="center">
  <table>
    <tr>
      <td><img src="assets\images\inspiration\home.png" alt="Search Interface" width="250"/></td>
      <td><img src="assets\images\inspiration\thinking.png" alt="Trip Details" width="250"/></td>
      <td><img src="assets\images\inspiration\itinerary.png" alt="Chat Interface" width="250"/></td>
    </tr>
    <tr>
      <td><img src="assets\images\inspiration\followup.png" alt="Search Interface" width="250"/></td>
      <td><img src="assets\images\inspiration\limit.png" alt="Chat Interface" width="250"/></td>
    </tr>
    <tr>
      <td align="center"><b>AI Search Interface</b></td>
      <td align="center"><b>Trip Planning Details</b></td>
      <td align="center"><b>Interactive Chat</b></td>
    </tr>
  </table>
</div>

## 🌟 Project Overview

**Pathoria** is a revolutionary travel planning application that harnesses the power of artificial intelligence and the Google Search API to transform how users plan their trips. By integrating natural language processing with real-time information retrieval, Pathoria creates a seamless bridge between a user's travel aspirations and actionable travel plans.

> **"Planning your dream trip should be as simple as having a conversation."**

With Pathoria, users can simply express their travel desires in natural language (e.g., "7 days in Kyoto next April, solo, mid-range budget"), and the app's AI systems interpret these requests, query relevant information through Google Search, and present curated travel options complete with accommodations, attractions, restaurants, and transportation details.

## 🧠 AI & Technical Innovations

### 🤖 Advanced AI Integration

Pathoria leverages Groq's high-performance LLM API to:

- **Generate complete travel itineraries** based on natural language requests
- **Extract key travel preferences** like destinations, duration, budgets, and styles
- **Structure detailed day-by-day plans** with activities, times, and locations
- **Respond to follow-up questions** with context-aware refinements

### 🔍 Intelligent Response Processing

Our custom-built system delivers:

- **Streamed real-time responses** with typing indicators for improved UX
- **Structured itinerary formatting** with consistent presentation across requests
- **Contextual follow-up handling** that understands previous itinerary details
- **Smart token and cost management** to optimize API usage and stay within limits

### 💬 Conversational Planning Interface

The chat-based interface provides:

- **Dynamic itinerary refinement** through natural follow-up questions
- **Context preservation** throughout the conversation
- **Visual itinerary presentation** with day-by-day breakdowns
- **Real-time updates and changes** as travel plans evolve
- **Offline access** to saved itineraries for travel without connectivity

### Near-Term Roadmap
- **Enhanced AI Prompting** - More specific and context-aware travel planning capabilities
- **Predictive Recommendations** - Suggesting activities based on user preferences and history
- **Alternative AI Models** - Support for multiple LLM providers with fallback options
- **Voice Interface** - Hands-free trip planning through voice commands
- **Image Recognition** - Identify landmarks and points of interest from photos

### Long-Term Vision
- **Multimodal Planning** - Integrated flight, hotel, and activity booking
- **Personalized Recommendations** - Machine learning-based suggestion engine
- **Social Features** - Community sharing of trip plans and recommendations
- **Enterprise Solutions** - White-label version for travel industry partners
- **Hybrid AI Approach** - Combination of specialized travel models with general LLMs for optimal results

<!-- <div align="center">
  <img src="assets\images\inspiration\chat.png" alt="AI Conversation Flow" width="600"/>
  <p><i>Pathoria's intelligent conversation flow adapts to user inputs and preferences</i></p>
</div> -->

## ✨ Key Features

### 🚀 Core Capabilities

- **🔍 AI-Powered Search** - Natural language trip planning using advanced entity extraction
- **💬 Conversational Interface** - Dynamic chat with context-aware responses and suggestions
- **📱 Offline Trip Access** - Full access to saved trips without internet connection
- **🗺️ Smart Maps Integration** - One-tap access to locations with route planning
- **💰 Budget Management** - Track estimated costs across all trip elements
- **🔄 Real-Time Updates** - Live information about attractions, restaurants and accommodations
- **🌐 Multi-Destination Planning** - Support for complex itineraries across multiple locations

### User Experience Innovations

- **Personalization Engine** - Learning from user preferences to improve recommendations
- **Visual Trip Timeline** - Interactive day-by-day view of planned activities
- **Smart Notifications** - Context-aware alerts about reservations and activities
- **Share & Collaborate** - Trip sharing with co-travelers for collaborative planning
<!-- 
<div align="center">
  <img src="assets\images\inspiration\thinking.png" alt="Feature Showcase" width="600"/>
  <p><i>Pathoria's AI-powered search interface delivers personalized travel recommendations</i></p>
</div> -->

## 🏗️ Architecture & Technical Implementation

Pathoria follows **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability. The application is built with a forward-thinking approach to scalability and performance optimization.

### System Architecture

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

### Technical Stack Highlights

| Layer | Technology | Implementation Details |
|-------|------------|---------|
| **State Management** | Riverpod 3 | Reactive state management with provider observers and state notifiers for real-time UI updates |
| **AI Integration** | Groq AI API | High-performance LLM API integration with streaming responses for travel planning |
| **Navigation** | GoRouter | Advanced declarative routing with deep linking and path parameters |
| **Database** | Isar | Non-SQL database with complex indexing for offline trip storage and retrieval |
| **HTTP Client** | Dio + Retrofit | Type-safe API client with interceptors for authentication and error handling |
| **Authentication** | Firebase Auth | Multi-provider authentication with Google Sign-In and email |
| **Search Integration** | Web Search Service | Optional enrichment for travel-related information with context-based filtering |
| **Maps** | URL Launcher + Integration | Cross-platform map launching with route planning |
| **Caching** | Custom Cache Manager | Time-based and priority-based caching for AI responses with token usage tracking |

### Performance Optimizations

- **Lazy loading** of search results and images
- **Background processing** for intensive NLP operations
- **Result pagination** to handle large datasets efficiently
- **Memory-efficient storage** of trip plans and search history
- **Network bandwidth optimization** through selective data fetching

## 🚀 Development Approach

### Engineering Excellence

- **Test-Driven Development** - Comprehensive testing strategy with >80% code coverage
- **CI/CD Pipeline** - Automated testing and deployment with GitHub Actions
- **Code Quality** - Static analysis and linting enforced through pull request checks
- **Performance Monitoring** - Firebase Performance integration for real-world metrics
- **Crash Analytics** - Firebase Crashlytics for issue detection and resolution

### Architectural Decisions

- **Offline-First Design** - Application functions with or without network connectivity
- **Scalable Backend** - Firebase infrastructure for authentication and data storage
- **Cross-Platform Consistency** - Unified UX across iOS and Android with platform-specific optimizations
- **Maintainable Codebase** - Strict adherence to SOLID principles and design patterns
- **Future-Proof Structure** - Modular architecture allowing for feature expansion

## 📈 Technical Challenges & Solutions

| Challenge | Solution Implemented |
|-----------|---------------------|
| **Complex Travel Planning** | Implemented Groq AI integration with specialized prompt engineering for itinerary generation |
| **Streaming Responses** | Created stream-based UI updates for real-time generation with typing indicator |
| **Handling Ambiguous Requests** | Implemented clarification dialogues with follow-up refinement options |
| **Offline Data Synchronization** | Built bidirectional sync mechanism with conflict resolution for offline itineraries |
| **API Quota & Cost Management** | Designed intelligent caching and token tracking system with daily usage limits |
| **UI Responsiveness** | Implemented component-based architecture with optimized rendering patterns |
| **Consistent Error Handling** | Created standardized error components and recovery mechanisms across the app |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19.0+
- Dart SDK 3.3.0+
- Android Studio / VS Code
- Groq API credentials (required) - [Get API Key](https://console.groq.com/)
- Firebase project (required for authentication)
- Google Search API credentials (optional)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/YKbodgam/Smart-Trip-Planner.git
   cd pathoria
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   cp env.example .env
   # Edit .env with your API keys - Groq API key is required
   ```

4. **Firebase setup**
   ```bash
   # Install Firebase CLI if you haven't already
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in the project
   firebase init
   
   # Generate the firebase_options.dart file
   flutterfire configure
   ```

5. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Launch the app**
   ```bash
   flutter run
   ```

### Configuration Notes

- **Required APIs**: Groq API and Firebase are required for core functionality
- **Optional APIs**: Google Search API can be used to enrich travel information
- **Rate Limiting**: Adjust the rate limits in .env based on your API tier
- **Testing Mode**: Set `ENABLE_ANALYTICS=false` during development

### Environment Configuration

Create a `.env` file in the root directory based on the provided `.env.example`:

```env
# Groq API Configuration (Required - Main LLM)
GROQ_API_KEY=your_groq_api_key_here  # Required for AI features

# Firebase Configuration (Required for authentication)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id

# App Configuration
ENABLE_ANALYTICS=false               # Set to true for production
ENABLE_CRASH_REPORTING=false         # Set to true for production
ENABLE_PERFORMANCE_MONITORING=false  # Set to true for production
MAX_REQUESTS_PER_MINUTE=60           # API rate limiting
MAX_TOKENS_PER_DAY=10000             # Daily token usage limit
MAX_COST_PER_DAY=50.0                # Daily cost limit in USD
```

## 📱 App Structure

```
lib/
├── 📱 app.dart                   # Application configuration and initialization
├── 🚀 main.dart                  # Entry point with dependency injection
├── 🔐 firebase_options.dart      # Firebase configuration
└── src/
    ├── 🏗️ core/                  # Foundation components
    │   ├── config/               # Environment configuration
    │   ├── constants/            # Application constants
    │   ├── error/                # Error handling and reporting
    │   ├── router/               # Navigation system
    │   ├── theme/                # UI theming and styling
    │   └── utils/                # Helper utilities and extensions
    ├── 📊 data/                  # Data management
    │   ├── models/               # Data structures and DTOs
    │   ├── repositories/         # Data access implementations
    │   │   └── *_impl.dart       # Repository implementations
    │   └── services/             # External service integrations
    │       ├── groq_service.dart # AI service for itinerary generation
    │       └── web_search_service.dart # Optional search enrichment
    ├── 🤖 domain/                # Business logic
    │   ├── entities/             # Core business objects
    │   │   ├── chat_message.dart # Chat message entity
    │   │   ├── itinerary.dart    # Itinerary entity structure
    │   │   └── user.dart         # User entity
    │   ├── repositories/         # Data access interfaces
    │   └── usecases/             # Business operations
    └── 🎨 presentation/          # User interface
        ├── providers/            # State management with Riverpod
        │   ├── auth_provider.dart         # Authentication state
        │   ├── chat_provider.dart         # Chat & AI interaction
        │   └── repository_providers.dart  # Repository providers
        ├── screens/              # Application views
        │   ├── auth/             # Authentication screens
        │   ├── chat/             # Chat interface
        │   ├── home/             # Home screen
        │   ├── itinerary/        # Itinerary details
        │   └── profile/          # User profile
        └── widgets/              # Reusable UI components
            ├── chat/             # Chat-specific components
            │   ├── chat_input_field.dart        # Message input
            │   ├── chat_message_bubble.dart     # Message display
            │   ├── error_message_bubble.dart    # Error handling
            │   ├── itinerary_message_bubble.dart # Itinerary view
            │   ├── loading_message_bubble.dart  # Loading states
            │   └── typing_indicator_bubble.dart # Streaming indicator
            └── common/           # Shared components
                ├── feedback_widgets.dart  # Error and loading displays
                ├── send_button.dart       # Reusable send button
                └── user_avatar.dart       # User and AI avatars
```

## 🧪 Testing & Quality Assurance

Our comprehensive testing strategy ensures reliability and performance:

- **Unit Tests** - Business logic, repositories, and data transformations
- **Widget Tests** - UI components and user interactions
- **Integration Tests** - End-to-end user flows and system integration
- **Performance Tests** - Response time and resource utilization
- **AI Response Testing** - LLM output validation and consistency checking
- **Offline Mode Testing** - Functionality verification in disconnected scenarios
- **UI Component Testing** - Visual consistency across different screen sizes and platforms

## 📚 Documentation & Resources

- [📖 APP Documentation](docs/documentation.md) - Detailed API integration guides

## � Future Development

### Near-Term Roadmap
- **Advanced NLP Models** - Improved understanding of complex travel requests
- **Predictive Recommendations** - Suggesting activities based on user preferences
- **AR Navigation Integration** - Augmented reality directions to points of interest
- **Voice Interface** - Hands-free trip planning through voice commands

### Long-Term Vision
- **Multimodal Planning** - Integrated flight, hotel, and activity booking
- **Personalized Recommendations** - Machine learning-based suggestion engine
- **Social Features** - Community sharing of trip plans and recommendations
- **Enterprise Solutions** - White-label version for travel industry partners

## 🚨 Implementation Challenges & Solutions

| Challenge | Solution Implemented |
|-----------|---------------------|
| **API Rate & Cost Limiting** | Intelligent caching and token tracking implemented to stay within usage limits |
| **Response Quality Control** | Specialized prompt engineering to ensure consistent itinerary formatting |
| **Streaming Response Handling** | Custom implementation for real-time UI updates during generation |
| **Offline Synchronization** | Conflict resolution for offline data changes with persistence |
| **Cross-Platform UI Consistency** | Component-based architecture with standardized styling |
| **Error Recovery** | Graceful failure handling with user-friendly messaging and retry options |
| **Performance Optimization** | Efficient state management to prevent unnecessary re-renders |
| **Modular Widget Structure** | Reusable UI components with consistent styling across the application |

## 🤝 Contributions & Development

This project follows standard GitHub flow:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please read our [Contributing Guide](docs/contributing.md) for details on our code standards.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍� About the Developer

Pathoria was developed by Yahya Bodgam, a software engineer specializing in mobile application development with expertise in:

- Flutter and Dart ecosystem
- AI integration in mobile applications
- Clean Architecture implementation
- User experience design
- Performance optimization
- Cross-platform development

Connect with me on [LinkedIn](www.linkedin.com/in/crimsondev) or [GitHub](https://github.com/YKbodgam).

## �🙏 Acknowledgments

- **Flutter Team** - For their powerful cross-platform framework
- **Google** - For comprehensive search capabilities and Firebase infrastructure
- **Riverpod Team** - For revolutionary state management solutions
- **Isar Database** - For high-performance local storage
- **Open Source Community** - For invaluable libraries and contributions

## 📞 Support & Contact

- **Issues**: [GitHub Issues](https://github.com/YKbodgam/Smart-Trip-Planner.git/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YKbodgam/Smart-Trip-Planner.git/discussions)
- **Wiki**: [Project Wiki](https://github.com/YKbodgam/Smart-Trip-Planner.git/wiki)
- **Email**: yahya.bodgam@gmail.com

## 🏆 Recent Improvements (September 2025)

The application has undergone significant refactoring and improvements:

1. **AI Service Consolidation**
   - Consolidated redundant AI service implementations into a single, optimized `groq_service.dart`
   - Added proper caching mechanisms to reduce API calls and improve performance
   - Implemented streaming responses for better user experience

2. **Component-based Architecture**
   - Created a library of reusable UI components like `UserAvatar`, `AIAvatar`, and `SendButton`
   - Standardized error handling with the `ErrorDisplay` component
   - Improved loading states with consistent `LoadingIndicator` and typing animations

3. **Performance Optimizations**
   - Reduced unnecessary widget rebuilds through proper state management
   - Implemented efficient stream handling for real-time updates
   - Added token usage tracking to stay within API limits

4. **UX Improvements**
   - Enhanced chat interface with clear visual distinction between user and AI messages
   - Added interactive elements for itinerary refinement and offline saving
   - Implemented consistent error recovery mechanisms throughout the app

---

<div align="center">
  <b>Transform your travel dreams into reality with AI-powered planning!</b>
  <br>
  <i>Made with ❤️ and ☕</i>
  <br>
  <i>Last updated: September 2025</i>
</div>
