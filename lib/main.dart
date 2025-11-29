import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:leakuku/core/services/notification_service.dart';
import 'package:leakuku/data/models/user_model.dart';
import 'package:leakuku/data/models/breed_model.dart';
import 'package:leakuku/data/models/vaccine_model.dart';
import 'package:leakuku/data/models/weekly_plan_model.dart';
import 'package:leakuku/features/flock/domain/flock_model.dart';
import 'package:leakuku/data/datasources/breed_local_data_source.dart';
import 'package:leakuku/features/auth/presentation/login_register_page.dart';
import 'package:leakuku/features/flock/presentation/dashboard_page.dart';
import 'package:leakuku/features/flock/presentation/flock_page.dart';
import 'package:leakuku/features/profile/presentation/profile_page.dart';
import 'package:leakuku/features/notifications/presentation/notifications_page.dart';
import 'package:leakuku/features/progress/presentation/progress_page.dart';
import 'package:leakuku/features/reports/presentation/reports_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone database
  tz.initializeTimeZones();
  
  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters (use generated classes, no casts)
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(FlockModelAdapter());
  Hive.registerAdapter(BreedModelAdapter());
  Hive.registerAdapter(VaccineModelAdapter());
  Hive.registerAdapter(WeeklyPlanModelAdapter());

  // Open boxes
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<FlockModel>('flockBox');
  final breedBox = await Hive.openBox<BreedModel>('breedBox');
  await Hive.openBox<List<dynamic>>('vaccineBox');
  await Hive.openBox<List<dynamic>>('weeklyPlanBox');

  // Seed default breeds
  final breedDataSource = BreedLocalDataSourceImpl(breedBox: breedBox);
  await breedDataSource.seedDefaultBreeds();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeaKuku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
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

