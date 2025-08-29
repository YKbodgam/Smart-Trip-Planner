import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/itinerary/itinerary_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isOnAuthScreen =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isOnSplash = state.matchedLocation == '/splash';

      // If on splash, don't redirect
      if (isOnSplash) return null;

      // If not authenticated and not on auth screen, redirect to login
      if (!isAuthenticated && !isOnAuthScreen) {
        return '/login';
      }

      // If authenticated and on auth screen, redirect to home
      if (isAuthenticated && isOnAuthScreen) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(body: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'chat',
                name: 'chat',
                builder: (context, state) {
                  final itineraryId = state.uri.queryParameters['itineraryId'];
                  final prompt = state.uri.queryParameters['prompt'];
                  return ChatScreen(
                    itineraryId: itineraryId,
                    initialPrompt: prompt,
                  );
                },
              ),
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'itinerary/:id',
                name: 'itinerary-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ItineraryDetailScreen(itineraryId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
