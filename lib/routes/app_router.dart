import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lesson_7/provider/auth/auth_provider.dart';
import 'package:lesson_7/screens/auth/forgot_password_screen.dart';
import 'package:lesson_7/screens/auth/login_screen.dart';
import 'package:lesson_7/screens/auth/signup_screen.dart';
import 'package:lesson_7/screens/auth/verification_screen.dart';
import 'package:lesson_7/screens/home_screen.dart';
import 'package:lesson_7/screens/profile_screen.dart';
import 'package:lesson_7/screens/splash_screen.dart';
import 'package:lesson_7/screens/discover_screen.dart';
import 'package:lesson_7/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateStream = ref.watch(authStateProvider.stream);
  final authService = ref.watch(authServiceProvider);
  final splashAsync = ref.watch(splashDelayProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStreamNotifier(authStateStream),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => EmailVerificationScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
      GoRoute(
          path: '/discover',
          builder: (context, state) => const DiscoverScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
    ],
    redirect: (context, state) async {
      if (splashAsync.isLoading) return null;
      final isAuthenticated = ref.read(authStateProvider).valueOrNull != null;
      final isAuthenticating = ref.read(authStateProvider).isLoading;
      final needsVerification = authService.needsEmailVerification();
      final currentLocation = state.uri.toString();

      if (isAuthenticating) {
        return currentLocation == '/splash' ? null : '/splash';
      }

      final isAuthRoute = currentLocation == '/login' ||
          currentLocation == '/signup' ||
          currentLocation == '/forgot-password';

      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

      if (isAuthenticated) {
        if (needsVerification) {
          return currentLocation == '/verification' ? null : '/verification';
        } else if (!onboardingComplete) {
          return currentLocation == '/onboarding' ? null : '/onboarding';
        } else {
          return currentLocation == '/home' ? null : '/home';
        }
      } else {
        return isAuthRoute ? null : '/login';
      }
    },
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text("Error: ${state.error}"))),
  );
});

class GoRouterRefreshStreamNotifier extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStreamNotifier(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final splashDelayProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(seconds: 3));
});
