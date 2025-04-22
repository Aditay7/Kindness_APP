import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Check onboarding and login status after animation
    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!mounted) return;

      if (!onboardingCompleted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else if (isLoggedIn) {
        // Get user type and navigate to appropriate dashboard
        String userType = prefs.getString('userType') ?? 'restaurant';
        if (userType.toLowerCase() == 'ngo') {
          Navigator.pushReplacementNamed(context, '/ngo-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/restaurant-dashboard');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Image.asset(
                'assets/icons/main_icon.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                'Kindness',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Tagline
              Text(
                'Bringing hearts and food together',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
