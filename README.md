# CreatorPilot AI — Mobile App

AI-powered YouTube growth insights for creators. A production-grade Flutter mobile application that connects to the [creatorpilot-api](../creatorpilot-api) and [creatorpilot-mcp](../creatorpilot-mcp) backend services.

---

## Features

### Phase 1 (Current)

| Feature | Description |
|---|---|
| **Native iOS OAuth** | Connect your channel via `flutter_appauth` (PKCE, no client secret on device) |
| **Bottom Navigation** | 2-tab layout — Dashboard + AI Assistant with state-preserved tabs |
| **Dashboard** | Channel KPIs (subscribers, views, videos), top video card, usage counter |
| **AI Chat Assistant** | Full conversational UI with message bubbles, suggestion chips, usage counter |
| **Video Analysis** | Tap any video for performance snapshots, growth signals, and recommendations |
| **Plan Limit Handling** | Free tier: 3 queries/day with upgrade prompts when exhausted |
| **PRO Upgrade Modal** | Feature comparison and CTA (payment integration in Phase 2) |
| **Session Persistence** | Encrypted local storage via FlutterSecureStorage |
| **Smart Number Formatting** | ICU compact notation (1.9K, 258K) via `intl` package |

---

## Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter (stable channel) |
| State Management | Riverpod (`AsyncNotifier`, `FutureProvider`, `StateNotifier`) |
| Routing | GoRouter (declarative, auth-aware) |
| Networking | Dio (centralized client, interceptors) |
| OAuth | `flutter_appauth` (native iOS PKCE flow) |
| Data Models | Freezed + json_annotation |
| Secure Storage | FlutterSecureStorage |
| Typography | Google Fonts (Inter) |
| Number Formatting | `intl` (ICU compact notation) |
| Design System | Material 3, dark theme |

---

## Architecture

Clean architecture with feature-based modules:

```
lib/
├── main.dart                              # Entry point — ProviderScope + MaterialApp.router
│
├── core/                                  # App-wide infrastructure
│   ├── config/
│   │   ├── app_config.dart                # Environment config (base URL, timeouts, default user)
│   │   └── app_router.dart                # GoRouter — /splash, /login, /dashboard (→ MainShell), /video/:id
│   ├── constants/
│   │   └── constants.dart                 # API path constants, app constants
│   ├── theme/
│   │   ├── app_colors.dart                # Dark theme color palette with gradients
│   │   ├── app_text_styles.dart           # Typography scale (display → label)
│   │   └── app_theme.dart                 # Material 3 ThemeData configuration
│   └── utils/
│       └── number_formatter.dart          # ICU compact (1.9K) + exact (1,930) formatting
│
├── services/                              # Shared API services (Riverpod providers)
│   ├── api_client.dart                    # Dio singleton with logging + error interceptors
│   ├── auth_service.dart                  # Session CRUD, user status
│   ├── google_auth_service.dart           # Native iOS OAuth via flutter_appauth + backend exchange
│   ├── analytics_service.dart             # Channel stats, top video
│   └── video_service.dart                 # AI query execution via /execute
│
├── features/                              # Feature modules (clean architecture)
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository_impl.dart  # Maps AuthService → domain entities
│   │   ├── domain/
│   │   │   ├── entities/user.dart         # User entity (plan, usage, limits)
│   │   │   └── repositories/auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/auth_providers.dart  # AuthStateNotifier (login/logout/refresh)
│   │       └── screens/
│   │           ├── splash_screen.dart      # Animated splash with session check
│   │           └── login_screen.dart       # Native Google OAuth connect button
│   │
│   ├── shell/
│   │   └── main_shell.dart                # BottomNavigationBar + IndexedStack (Dashboard | Assistant)
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   │   └── dashboard_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── channel_stats.dart     # Subscriber count, views, daily chart
│   │   │   │   ├── top_video.dart         # Top video with thumbnail & growth %
│   │   │   │   └── ask_result.dart        # AI response with confidence score
│   │   │   └── repositories/dashboard_repository.dart
│   │   └── presentation/
│   │       ├── providers/dashboard_providers.dart  # Stats, top video providers
│   │       ├── screens/dashboard_screen.dart       # SafeArea + LayoutBuilder composition
│   │       └── widgets/
│   │           ├── welcome_header.dart    # Greeting + channel name + PRO badge
│   │           ├── usage_badge.dart       # Query counter (0/3) with progress ring
│   │           ├── top_video_card.dart    # Thumbnail + stats (compact/full modes)
│   │           ├── ask_box.dart           # AI input with gradient send button
│   │           └── result_panel.dart      # AI response card with confidence bar
│   │
│   ├── chat/
│   │   ├── chat_providers.dart            # ChatMessage model + StateNotifier
│   │   └── chat_screen.dart              # Full chat UI: bubbles, suggestions, input, upgrade CTA
│   │
│   ├── video/
│   │   ├── data/
│   │   │   └── video_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/video_analysis.dart
│   │   │   └── repositories/video_repository.dart
│   │   └── presentation/
│   │       ├── providers/video_providers.dart
│   │       └── screens/video_analysis_screen.dart  # Hero thumbnail + insight cards
│   │
│   └── premium/
│       └── presentation/
│           └── screens/upgrade_modal.dart  # Feature comparison + upgrade CTA
│
└── shared/                                # Reusable UI components
    ├── widgets/
    │   ├── loading_skeleton.dart           # Shimmer placeholder
    │   ├── error_state.dart               # Error message + retry button
    │   └── premium_card.dart              # Card with border + optional gradient
    └── layout/
        └── app_scaffold.dart              # SafeArea + consistent background
```

---

## Authentication

### Native iOS OAuth (PKCE)

The app uses `flutter_appauth` for a fully native OAuth flow:

1. **Flutter** calls `appAuth.authorize()` with the iOS client ID and PKCE code verifier
2. User authenticates in native browser — no WebView
3. **Flutter** receives the authorization code + code_verifier
4. **Flutter** sends both to `POST /auth/youtube/mobile/exchange`
5. **Backend** exchanges the code with Google (using code_verifier, no client_secret)
6. **Backend** stores tokens, connects channel, returns session

> **Security:** Client secret never leaves the server. PKCE protects the code exchange. No sensitive tokens stored on device.

---

## API Endpoints

All endpoints are proxied through `creatorpilot-api` (FastAPI gateway) to `creatorpilot-mcp`.

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/v1/auth/youtube/mobile/exchange` | Native OAuth code exchange (PKCE) |
| `GET` | `/api/v1/user/status` | User plan, query usage, limit status |
| `GET` | `/api/v1/channel/stats` | Channel KPIs (subscribers, views, videos) |
| `GET` | `/api/v1/channel/top-video` | Top performing video for period |
| `POST` | `/api/v1/execute` | AI query execution |

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel, ≥3.2.0)
- Xcode 15+ (for iOS builds)
- Running backend services:
  - `creatorpilot-api` (default: `http://localhost:8000`)
  - `creatorpilot-mcp` (default: `http://localhost:8001`)

### Setup

```bash
# Clone and enter the project
cd creatorpilot-mobile

# Install dependencies
flutter pub get

# Configure backend URL (edit lib/core/config/app_config.dart)
# Default: http://localhost:8000

# Run on iOS simulator
flutter run -d "iPhone 16e"
```

### Environment Configuration

Edit `lib/core/config/app_config.dart` to set:

| Config | Default | Description |
|---|---|---|
| `apiBaseUrl` | `http://localhost:8000` | Backend API gateway URL |
| `apiTimeoutSeconds` | `30` | HTTP request timeout |
| `defaultUserId` | `00000000-0000-0000-0000-000000000001` | Test user ID |

---

## State Management

All state flows through **Riverpod** providers:

```
authStateProvider          → AsyncNotifier<User?>            (login/logout/refresh)
channelStatsProvider       → FutureProvider<ChannelStats>    (auto-refetch on auth change)
topVideoProvider           → FutureProvider<TopVideo>        (auto-refetch on auth change)
chatMessagesProvider       → StateNotifier<List<ChatMessage>> (chat history)
videoAnalysisProvider      → FutureProvider.family<..., String>  (keyed by video ID)
```

### Data Flow

```
User Action → Provider Notifier → Repository → Service → Dio → Backend API
                                                                    ↓
UI ← AsyncValue.when() ← Provider State ← Domain Entity ← JSON Response
```

---

## Navigation

### Bottom Navigation Shell

The app uses a `MainShell` widget with `IndexedStack` for tab-based navigation:

| Tab | Screen | Description |
|---|---|---|
| Dashboard | `DashboardScreen` | KPIs, stats row, top video card |
| AI Assistant | `ChatScreen` | Chat bubbles, suggestions, input, usage counter |

State is preserved between tabs via `IndexedStack`.

### Routes

| Route | Screen | Description |
|---|---|---|
| `/splash` | SplashScreen | Animated logo, session check, auto-redirect |
| `/login` | LoginScreen | Native Google OAuth connect button |
| `/dashboard` | MainShell | Bottom nav with Dashboard + AI Assistant tabs |
| `/video/:videoId` | VideoAnalysisScreen | Hero thumbnail, AI insight cards |

---

## UX Design Principles

- **Dark theme** with premium feel — no default Material colors
- **Card-based layout** with subtle borders and gradient accents
- **Shimmer loading** skeletons instead of spinners
- **Color-coded** usage states (green → amber → red)
- **Compact number formatting** — 1.9K, 258K, 1.2M (via `intl`)
- **No raw JSON** — all AI responses formatted into insight cards
- **No emojis** in professional screens
- **Clean whitespace** and consistent typography (Inter font family)
- **SafeArea + LayoutBuilder** — no bottom overflow on any device

---

## Dependencies

### Runtime
| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `go_router` | ^14.2.0 | Declarative routing |
| `dio` | ^5.4.1 | HTTP client |
| `flutter_appauth` | ^7.0.0 | Native iOS OAuth (PKCE) |
| `flutter_secure_storage` | ^9.0.0 | Encrypted session storage |
| `cached_network_image` | ^3.3.1 | Image caching |
| `shimmer` | ^3.0.0 | Loading placeholders |
| `google_fonts` | ^6.1.0 | Inter font family |
| `intl` | ^0.19.0 | Number formatting (ICU compact) |
| `url_launcher` | ^6.2.5 | External URLs |
| `freezed_annotation` | ^2.4.1 | Data class annotations |

### Dev
| Package | Version | Purpose |
|---|---|---|
| `build_runner` | ^2.4.8 | Code generation runner |
| `freezed` | ^2.4.7 | Immutable data classes |
| `json_serializable` | ^6.7.1 | JSON serialization |
| `riverpod_generator` | ^2.4.0 | Provider code generation |

---

## Recent Updates

- **Intelligent Chat UX**:
  - **Rich Text & Subheadings**: AI messages now parse markdown `**bold**` syntax for stronger visual hierarchy and subheadings.
  - **Animated Loading State**: Replaced static loading dots with a premium `AnimatedSwitcher` containing a smooth `AnimatedTypingIndicator` and a sequential `RotatingStatusText` ("Analyzing video performance...", etc).
  - **Dynamic Input Box**: Added a custom 3D glossy chat icon to the user input field.
  - **Per-message Actions**: Added inline thumbs up/down and copy-to-clipboard functionality to all AI responses.
- **Plan Enforcement UI**:
  - Implemented real-time usage counter logic with proactive send-button disabling when Free limits are exhausted.
  - New visually distinct PRO upgrade modal and feature gates linked to backend `FORCE_PRO_MODE`.

---

## Roadmap

### Phase 2
- [ ] Payment integration (Stripe / RevenueCat)
- [ ] Push notifications
- [ ] Full channel analytics dashboard with charts
- [ ] Content calendar / scheduling
- [ ] Multi-channel support
- [ ] Chat history persistence

---

## License

Private — internal use only.
