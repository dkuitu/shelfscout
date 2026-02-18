import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/submission/submission_screen.dart';
import '../screens/submission/camera_screen.dart';
import '../screens/submission/confirm_screen.dart';
import '../screens/submission/suggest_item_screen.dart';
import '../screens/submission/pending_items_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/badges_screen.dart';
import '../screens/leaderboard/leaderboard_screen.dart';
import '../screens/validation/validation_queue_screen.dart';
import '../screens/validation/validation_detail_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String map = '/map';
  static const String submission = '/submission';
  static const String camera = '/camera';
  static const String confirm = '/confirm';
  static const String suggestItem = '/suggest-item';
  static const String pendingItems = '/pending-items';
  static const String profile = '/profile';
  static const String badges = '/badges';
  static const String leaderboard = '/leaderboard';
  static const String validationQueue = '/validation';
  static const String validationDetail = '/validation/detail';

  static Map<String, WidgetBuilder> get routes => {
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        map: (_) => const MapScreen(),
        submission: (_) => const SubmissionScreen(),
        camera: (_) => const CameraScreen(),
        confirm: (_) => const ConfirmScreen(),
        suggestItem: (_) => const SuggestItemScreen(),
        pendingItems: (_) => const PendingItemsScreen(),
        profile: (_) => const ProfileScreen(),
        badges: (_) => const BadgesScreen(),
        leaderboard: (_) => const LeaderboardScreen(),
        validationQueue: (_) => const ValidationQueueScreen(),
        validationDetail: (_) => const ValidationDetailScreen(),
      };
}
