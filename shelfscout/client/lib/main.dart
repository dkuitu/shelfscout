import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/map_provider.dart';
import 'providers/submission_provider.dart';
import 'providers/crown_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/validation_provider.dart';
import 'providers/user_provider.dart';
import 'providers/item_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient();
  runApp(ShelfScoutApp(apiClient: apiClient));
}

class ShelfScoutApp extends StatelessWidget {
  final ApiClient apiClient;

  const ShelfScoutApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => MapProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SubmissionProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CrownProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ValidationProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => UserProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ItemProvider(apiClient)),
      ],
      child: MaterialApp(
        title: 'ShelfScout',
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
