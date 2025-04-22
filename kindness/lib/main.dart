import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/restaurant_signup_screen.dart';
import 'screens/auth/ngo_signup_screen.dart';
import 'screens/restaurant/restaurant_dashboard_screen.dart';
import 'screens/ngo/ngo_dashboard_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations first
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Optimize image cache
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB

  runApp(MyApp(
    notificationService: notificationService,
    initialRoute: '/splash', // Always start with splash screen
  ));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final String initialRoute;

  const MyApp({
    Key? key,
    required this.notificationService,
    required this.initialRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: notificationService.navigatorKey,
      title: 'Kindness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: initialRoute,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/restaurant-signup': (context) => const RestaurantSignupScreen(),
        '/ngo-signup': (context) => const NGOSignupScreen(),
        '/restaurant-dashboard': (context) => const RestaurantDashboardScreen(),
        '/ngo-dashboard': (context) => const NGODashboardScreen(),
        '/dashboard': (context) => const RestaurantDashboardScreen(),
      },
    );
  }
}
