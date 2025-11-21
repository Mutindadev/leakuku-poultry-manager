import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leakuku/data/models/user_model.dart';
import 'package:leakuku/data/models/user_model_adapter.dart';

import 'package:leakuku/features/auth/presentation/login_register_page.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/features/flock/presentation/dashboard_page.dart';
import 'package:leakuku/features/flock/presentation/flock_page.dart';
import 'package:leakuku/features/profile/presentation/profile_page.dart';
import 'package:leakuku/features/notifications/presentation/notifications_page.dart';
import 'package:leakuku/features/progress/presentation/progress_page.dart';
import 'package:leakuku/features/reports/presentation/reports_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(FlockModelAdapter());
  
  // Open boxes
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<FlockModel>('flockBox');

  runApp(const ProviderScope(child: LeaKukuApp()));
}

class LeaKukuApp extends StatelessWidget {
  const LeaKukuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeaKuku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFFF9800),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginRegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/flock': (context) => const FlockPage(),
        '/profile': (context) => const ProfilePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/progress': (context) => const ProgressPage(showAppBar: true),
        '/reports': (context) => const ReportsPage(),
      },
    );
  }
}

