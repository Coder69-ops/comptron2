import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/base_layout.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
// import 'core/services/mongodb_service.dart'; // Disabled for offline mode
import 'core/services/local_storage_service.dart';
import 'core/models/user.dart';
import 'features/auth/presentation/screens/auth_wrapper.dart';
import 'database_test_screen.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Center;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services (MongoDB disabled for offline mode)
  await Future.wait([
    AuthService.getInstance(),
    NotificationService.getInstance(),
    // MongoDBService.getInstance(), // Disabled - working in offline mode
    LocalStorageService.getInstance(),
  ]);

  // Ensure admin user exists for testing
  await _ensureAdminUser();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MyApp(),
    ),
  );
}

Future<void> _ensureAdminUser() async {
  try {
    final storage = await LocalStorageService.getInstance();

    // Force recreate admin user to ensure correct password hash
    print('Creating/updating admin user for testing...');

    final adminUser = User(
      id: ObjectId(),
      email: 'admin@comptron.dev',
      name: 'Admin User',
      avatarUrl: '',
      role: UserRole.admin,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Hash password (simple hash for testing)
    const password = 'admin123';
    final hashedPassword = password.hashCode.toString();

    await storage.saveUserWithPassword(adminUser, hashedPassword);
    print('Admin user created/updated: admin@comptron.dev / admin123');
    print('Password hash: $hashedPassword');

    // Verify the user can be retrieved
    final testUser = await storage.getUserByEmailAndPassword(
      'admin@comptron.dev',
      hashedPassword,
    );
    if (testUser != null) {
      print('✓ Admin user verification successful');
    } else {
      print('✗ Admin user verification failed');
    }
  } catch (e) {
    print('Error ensuring admin user: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Comptron',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/home': (context) => const BaseLayout(),
            '/db-test': (context) => const DatabaseTestScreen(),
          },
        );
      },
    );
  }
}
