import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  // Ensure the app targets the deployed backend by default
  setBaseUrl(
      'https://smartstudyassistantbackend-abdwc2fkdzhybncn.uaenorth-01.azurewebsites.net/api');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadFromStorage(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Smart Study Assistant',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: auth.isAuthenticated
                ? (auth.isAdmin ? '/admin' : '/dashboard')
                : '/login',
            routes: {
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
              '/dashboard': (_) => const DashboardScreen(),
              '/notes': (_) => const NotesScreen(),
              '/tasks': (_) => const TasksScreen(),
              '/ai': (_) => const AiScreen(),
              '/analytics': (_) => const AnalyticsScreen(),
              '/admin': (_) => const AdminScreen(),
            },
          );
        },
      ),
    );
  }
}
