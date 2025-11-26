import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'config/app_config.dart';
import 'services/supabase_service.dart';
import 'services/firebase_notification_service.dart';
import 'providers/sensor_provider.dart';
import 'screens/notification_screen.dart';
import 'providers/buzzer_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('❌ Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  try {
    // Initialize Supabase (works on all platforms)
    await SupabaseService.initialize(
      supabaseUrl: AppConfig.supabaseUrl,
      supabaseAnonKey: AppConfig.supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully');

    // Initialize Firebase (only on supported platforms)
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        kIsWeb) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase initialized successfully');

        // Initialize Firebase Messaging (only on mobile)
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          try {
            await FirebaseNotificationService().initialize();
            print('✅ Firebase Messaging initialized successfully');
          } catch (e) {
            print('⚠️ Firebase Messaging initialization failed: $e');
            print('App will continue without push notifications');
          }
        }
      } catch (e) {
        print('⚠️ Firebase initialization failed: $e');
        print('App will continue without Firebase features');
      }
    } else {
      print(
        '⚠️ Firebase not available on this platform (Desktop). Running without push notifications.',
      );
    }
  } catch (e, stackTrace) {
    print('❌ Critical error during initialization: $e');
    print('Stack trace: $stackTrace');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => BuzzerProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Fridge Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(elevation: 2),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        home: const DashboardScreen(),
        routes: {'/notifications': (context) => const NotificationScreen()},
      ),
    );
  }
}
