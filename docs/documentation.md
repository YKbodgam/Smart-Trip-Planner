# Pathoria Smart Trip Planner - Documentation

## 📚 Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [API Documentation](#api-documentation)
4. [Environment Setup](#environment-setup)
5. [Project Analysis](#project-analysis)
6. [Project Rules](#project-rules)

## Overview

Pathoria is an AI-powered Smart Trip Planner that helps users create, refine and manage travel itineraries through a natural language chat interface. The application leverages AI (OpenAI APIs), web search integration, and maps services to provide comprehensive travel planning assistance.

## Architecture

### Architecture Overview
Pathoria follows Clean Architecture principles to ensure maintainability, testability, and scalability.

### Architecture Layers

#### 1. Presentation Layer
**Location**: `lib/presentation/`

**Responsibilities**:
- UI components and screens
- State management with Riverpod
- User input handling
- Navigation

**Key Components**:
- **Screens**: Full-screen UI components
- **Widgets**: Reusable UI components
- **Providers**: State management and business logic coordination

#### 2. Domain Layer
**Location**: `lib/domain/`

**Responsibilities**:
- Business entities
- Use cases (business logic)
- Repository interfaces
- Core business rules

**Key Components**:
- **Entities**: Core business objects
- **Use Cases**: Single-purpose business operations
- **Repositories**: Data access interfaces

#### 3. Data Layer
**Location**: `lib/data/`

**Responsibilities**:
- Data models and DTOs
- Repository implementations
- External service integrations
- Data persistence

**Key Components**:
- **Models**: Data transfer objects
- **Repositories**: Data access implementations
- **Services**: External API integrations
- **Data Sources**: Local and remote data access

#### 4. Core Layer
**Location**: `lib/core/`

**Responsibilities**:
- Shared utilities
- Configuration
- Error handling
- Constants and themes

### Dependency Flow

```
Presentation → Domain ← Data
     ↓           ↓       ↓
   Core ←——————————————————
```

### Rules:
1. **Presentation** depends on **Domain**
2. **Data** depends on **Domain**
3. **Domain** is independent (no external dependencies)
4. **Core** is shared across all layers

### State Management

#### Riverpod Architecture
```dart
// Provider hierarchy
final repositoryProvider = Provider<Repository>((ref) => RepositoryImpl());

final useCaseProvider = Provider<UseCase>((ref) => 
  UseCase(ref.read(repositoryProvider)));

final viewModelProvider = StateNotifierProvider<ViewModel, State>((ref) => 
  ViewModel(ref.read(useCaseProvider)));
```

#### State Flow:
1. **UI** triggers action
2. **Provider** calls **Use Case**
3. **Use Case** executes business logic
4. **Repository** handles data operations
5. **State** updates trigger UI rebuild

### Error Handling

#### Error Propagation:
```
Data Layer → Domain Layer → Presentation Layer
   ↓             ↓              ↓
Exception → Failure → UI Error State
```

### Testing Strategy

#### Unit Tests
- **Domain Layer**: Use cases and entities
- **Data Layer**: Repository implementations
- **Utilities**: Helper functions

#### Widget Tests
- **Presentation Layer**: Individual widgets
- **Screen Tests**: Complete screen functionality

#### Integration Tests
- **End-to-End**: Complete user flows
- **API Integration**: External service communication

### Folder Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── app_config.dart          # App configuration
│   │   └── environment.dart         # Environment settings
│   ├── constants/
│   │   ├── app_constants.dart       # App-wide constants
│   │   └── api_constants.dart       # API endpoints
│   ├── error/
│   │   ├── exceptions.dart          # Custom exceptions
│   │   └── failures.dart            # Failure classes
│   ├── router/
│   │   └── app_router.dart          # Navigation configuration
│   ├── theme/
│   │   ├── app_theme.dart           # Theme configuration
│   │   └── app_colors.dart          # Color definitions
│   └── utils/
│       ├── screen_util_helper.dart  # Responsive design
│       └── validators.dart          # Input validation
├── data/
│   ├── datasources/
│   │   ├── local/                   # Local data sources
│   │   └── remote/                  # Remote data sources
│   ├── models/
│   │   ├── itinerary_model.dart     # Data models
│   │   └── user_model.dart
│   ├── repositories/
│   │   └── *_repository_impl.dart   # Repository implementations
│   └── services/
│       ├── ai_service.dart          # AI integration
│       └── auth_service.dart        # Authentication
├── domain/
│   ├── entities/
│   │   ├── itinerary.dart           # Business entities
│   │   └── user.dart
│   ├── repositories/
│   │   └── *_repository.dart        # Repository interfaces
│   └── usecases/
│       ├── create_itinerary.dart    # Business use cases
│       └── authenticate_user.dart
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart       # State providers
    │   └── itinerary_provider.dart
    ├── screens/
    │   ├── auth/                    # Authentication screens
    │   ├── home/                    # Home screen
    │   ├── chat/                    # Chat interface
    │   └── profile/                 # User profile
    └── widgets/
        ├── common/                  # Shared widgets
        ├── auth/                    # Auth-specific widgets
        └── itinerary/               # Itinerary widgets
```

## API Documentation

### API Integrations

Pathoria integrates with the following external APIs:

#### 1. OpenAI API
- **Purpose**: AI-powered chat and itinerary generation
- **Integration**: Direct HTTP calls with function/tool calling
- **Key Features**:
  - Stream responses for real-time chat experience
  - Function calling for structured itinerary data
  - Context management for conversation history

#### 2. Google Custom Search API
- **Purpose**: Web search for real-time travel information
- **Integration**: HTTP requests to Google Custom Search Engine
- **Key Features**:
  - Search for attractions, restaurants, and accommodations
  - Real-time information for itinerary generation
  - Location-aware search results

#### 3. Firebase Authentication
- **Purpose**: User authentication and management
- **Integration**: Firebase SDK
- **Key Features**:
  - Email/password authentication
  - Google sign-in
  - User profile management

#### 4. Maps Integration
- **Purpose**: Location services and map visualization
- **Integration**: Intent-based external map app opening
- **Key Features**:
  - Open locations in map applications
  - Get directions
  - View points of interest

### API Security and Best Practices

#### API Key Management
- API keys are stored in environment variables via `.env` file
- Keys are not committed to version control
- Different keys for development and production

#### Error Handling
- API errors are caught and mapped to user-friendly messages
- Network issues handled with appropriate retry mechanisms
- Rate limiting handled with exponential backoff

#### Rate Limiting
- Token usage tracking for AI API calls
- Request throttling when approaching limits
- User feedback when limits are reached

## Environment Setup

### Required Configuration Files

#### 1. Environment Variables (.env)

Create a `.env` file in the root directory of your project:

```env
# Pathoria Environment Configuration

# Google Search API (Required for search functionality)
GOOGLE_SEARCH_API_KEY=your_google_search_api_key_here
GOOGLE_SEARCH_ENGINE_ID=your_search_engine_id_here

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_API_KEY=your_firebase_api_key

# App Configuration
APP_NAME=Pathoria
APP_VERSION=1.0.0
ENVIRONMENT=development

# API Rate Limiting
MAX_REQUESTS_PER_MINUTE=60
REQUEST_TIMEOUT_SECONDS=30

# Feature Flags
ENABLE_WEB_SEARCH=true
ENABLE_MAPS_INTEGRATION=true
ENABLE_OFFLINE_MODE=true
```

#### 2. Firebase Configuration

**Android (google-services.json)**
Place `google-services.json` in `android/app/` directory.

**iOS (GoogleService-Info.plist)**
Place `GoogleService-Info.plist` in `ios/Runner/` directory.

### Getting API Keys

#### Google Search API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Custom Search API
4. Create credentials (API Key)
5. Create a Custom Search Engine at [Google Programmable Search Engine](https://programmablesearchengine.google.com/)
6. Copy both API key and Search Engine ID to your `.env` file

#### Firebase Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add Android and iOS apps
4. Download configuration files
5. Place them in the appropriate directories

### Environment-Specific Configurations

#### Development
```env
ENVIRONMENT=development
ENABLE_WEB_SEARCH=true
```

#### Staging
```env
ENVIRONMENT=staging
ENABLE_WEB_SEARCH=true
```

#### Production
```env
ENVIRONMENT=production
ENABLE_WEB_SEARCH=true
ENABLE_OFFLINE_MODE=true
```

### Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use different API keys** for different environments
3. **Rotate API keys** regularly
4. **Monitor API usage** to prevent abuse
5. **Use environment variables** instead of hardcoded values
6. **Validate configuration** at app startup

## Project Analysis

### Project Status

Pathoria Smart Trip Planner is currently in development with the following status:

#### Core Features (MVP)
- AI-Powered Itinerary Generation (client calls OpenAI, tool-calling) ✅
- Real-time Chat Interface (UI wired with Riverpod) ✅
- Offline Itinerary & Chat Storage (Hive) ✅
- Web Search Integration (Google CSE service) ✅
- Maps Integration (URL intents) ✅

#### Architecture
- Clean Architecture ✅
- Riverpod State Management ✅
- Local DB via Hive ✅
- GoRouter Navigation ✅

#### Technical Implementation
- OpenAI Integration via Dio ✅
- Streaming Responses ✅
- Web Search Service ✅
- Token Usage Tracking ✅
- Error Handling 🔄

#### Current MVP Completion Status

| Feature | Status | Progress |
|---------|--------|----------|
| **S-1: Create trip via chat** | ✅ Complete | 100% |
| **S-2: Refine itinerary** | 🔄 Partial | 70% |
| **S-3: Save & revisit** | ✅ Complete | 100% |
| **S-4: Offline view** | ✅ Complete | 100% |
| **S-5: Basic metrics** | ✅ Complete | 100% |
| **S-6: Web-search** | ✅ Complete | 100% |
| **Streaming UI** | ✅ Complete | 100% |
| **Error Handling** | 🔄 Partial | 60% |
| **Testing** | ❌ Minimal | 10% |
| **Code Quality** | 🔄 Needs Cleanup | 40% |

#### Remaining Tasks

1. Enhanced Diff UI for Refinements
2. Comprehensive Testing (Target ≥60%)
3. Error UX Enhancement
4. Environment Configuration Validation
5. Code Cleanup & Optimization

### Timeline to Completion

- Week 1: Enhanced diff UI + Error UX + Testing foundation
- Week 2: Comprehensive testing + Configuration validation
- Week 3: Code cleanup + Performance optimization + Final polish

## Project Rules

### Coding Standards

#### Naming Conventions

**Files & Directories**
```dart
// ✅ CORRECT: snake_case for files
user_profile_screen.dart
chat_message_bubble.dart
itinerary_repository_impl.dart

// ❌ WRONG: camelCase or PascalCase for files
userProfileScreen.dart
UserProfileScreen.dart
```

**Classes & Interfaces**
```dart
// ✅ CORRECT: PascalCase for classes
class UserProfileScreen extends StatelessWidget {}
class ChatMessageBubble extends StatelessWidget {}
class ItineraryRepositoryImpl implements ItineraryRepository {}

// ❌ WRONG: snake_case for classes
class user_profile_screen extends StatelessWidget {}
```

**Variables & Functions**
```dart
// ✅ CORRECT: camelCase for variables and functions
String userName = 'John';
void getUserProfile() {}
bool isUserLoggedIn = false;

// ❌ WRONG: snake_case for variables/functions
String user_name = 'John';
void get_user_profile() {}
bool is_user_logged_in = false;
```

**Constants**
```dart
// ✅ CORRECT: SCREAMING_SNAKE_CASE for constants
static const String API_BASE_URL = 'https://api.openai.com/v1';
static const int MAX_RETRY_ATTEMPTS = 3;
static const Duration REQUEST_TIMEOUT = Duration(seconds: 30);

// ❌ WRONG: camelCase for constants
static const String apiBaseUrl = 'https://api.openai.com/v1';
```

#### Code Organization

**File Structure**
```dart
// ✅ CORRECT: Organized imports
// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Third-party packages
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

// Local imports (relative paths)
import '../../core/theme/app_colors.dart';
import '../../domain/entities/user.dart';
import '../widgets/user_avatar.dart';
```

**Class Structure**
```dart
class ExampleClass extends StatelessWidget {
  // 1. Constants
  static const String _title = 'Example';
  
  // 2. Fields
  final String name;
  final VoidCallback onTap;
  
  // 3. Constructor
  const ExampleClass({
    super.key,
    required this.name,
    required this.onTap,
  });
  
  // 4. Lifecycle methods
  @override
  void initState() {
    super.initState();
    // Implementation
  }
  
  // 5. Private methods
  void _handleTap() {
    // Implementation
  }
  
  // 6. Public methods
  void publicMethod() {
    // Implementation
  }
  
  // 7. Build method (for widgets)
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### UI/UX Rules

#### Responsive Design
```dart
// ✅ CORRECT: Using ScreenUtil for responsive design
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w), // Responsive padding
      margin: EdgeInsets.symmetric(horizontal: 20.w), // Responsive margin
      child: Text(
        'Hello World',
        style: TextStyle(fontSize: 18.sp), // Responsive font size
      ),
    );
  }
}
```

#### Theme Consistency
```dart
// ✅ CORRECT: Using theme colors
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Primary Text',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)
```

#### Accessibility
```dart
// ✅ CORRECT: Accessible widgets
ElevatedButton(
  onPressed: _handleTap,
  child: Text('Save'),
  semanticsLabel: 'Save itinerary button', // Screen reader support
)
```

### Performance Rules

#### State Management
```dart
// ✅ CORRECT: Efficient state updates
class EfficientProvider extends StateNotifier<State> {
  void updateUser(User user) {
    // Only update if user actually changed
    if (state.user != user) {
      state = state.copyWith(user: user);
    }
  }
}
```

#### Widget Optimization
```dart
// ✅ CORRECT: Using const constructors
class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({super.key}); // const constructor
  
  @override
  Widget build(BuildContext context) {
    return const Text('Hello'); // const widget
  }
}
```

#### Database Operations
```dart
// ✅ CORRECT: Efficient database queries
class EfficientRepository {
  Future<List<Itinerary>> getRecentItineraries() async {
    return await _isar.itineraryModels
        .where()
        .createdAtGreaterThan(DateTime.now().subtract(Duration(days: 7)))
        .sortByCreatedAtDesc()
        .limit(10) // Limit results
        .findAll();
  }
}
```

### Security Rules

#### API Key Management
```dart
// ✅ CORRECT: Environment-based configuration
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get baseUrl => dotenv.env['OPENAI_BASE_URL'] ?? '';
}
```

#### Input Validation
```dart
// ✅ CORRECT: Input validation
class UserService {
  Future<User> createUser(String email, String password) async {
    // Validate input
    if (!_isValidEmail(email)) {
      throw ValidationException('Invalid email format');
    }
    
    if (!_isValidPassword(password)) {
      throw ValidationException('Password must be at least 8 characters');
    }
    
    // Process valid input
    return await _repository.createUser(email, password);
  }
}
```

#### Error Handling
```dart
// ✅ CORRECT: Secure error handling
try {
  final result = await _apiService.getData();
  return Right(result);
} catch (e) {
  // Log error for debugging (but don't expose sensitive info)
  _logger.error('API call failed', error: e);
  
  // Return user-friendly error message
  return Left(Failure('Unable to fetch data. Please try again later.'));
}
```

---

**Last Updated**: June 2023
