import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_router.dart';
import 'core/theme/app_theme.dart';

/// Entry point for CreatorPilot AI mobile app.
///
/// Architecture overview:
/// - [ProviderScope] wraps the entire app for Riverpod state management
/// - [GoRouter] handles declarative routing with auth-aware guards
/// - [AppTheme.darkTheme] provides Material 3 dark styling throughout
///
/// Feature modules follow clean architecture:
///   features/<name>/data/       → API calls, repository implementations
///   features/<name>/domain/     → Entities, repository interfaces
///   features/<name>/presentation/ → Screens, widgets, providers
///
/// Services layer (services/) provides shared API client, auth, analytics,
/// and video services — all exposed as Riverpod providers.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar icons for the dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: CreatorPilotApp(),
    ),
  );
}

/// Root application widget.
class CreatorPilotApp extends ConsumerWidget {
  const CreatorPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CreatorPilot AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
