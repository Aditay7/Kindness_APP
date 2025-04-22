import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Kindness',
      description:
          'Join us in making a difference by connecting restaurants with NGOs to reduce food waste and help those in need.',
      image: 'assets/animations/your_animation.json',
      gradient: AppTheme.primaryGradient,
    ),
    OnboardingPage(
      title: 'Track Donations',
      description:
          'Easily track your food donations and see the impact you\'re making in your community.',
      image: 'assets/animations/your_animation2.json',
      gradient: AppTheme.primaryGradient,
    ),
    OnboardingPage(
      title: 'Connect with Local NGOs',
      description:
          'Find and connect with NGOs in your area to ensure your donations reach those who need them most.',
      image: 'assets/animations/your_animation3.json',
      gradient: AppTheme.primaryGradient,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _pages[index].gradient,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  _pages[index].image,
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 40),
                                Text(
                                  _pages[index].title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _pages[index].description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryColor,
                                        height: 1.5,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(4),
                                color: _currentPage == index
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeInOutCubic,
                                );
                              } else {
                                // Set onboarding completed flag
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool(
                                    'onboardingCompleted', true);

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ).copyWith(
                              backgroundColor: MaterialStateProperty.all(
                                AppTheme.primaryColor,
                              ),
                            ),
                            child: Text(
                              _currentPage < _pages.length - 1
                                  ? 'Get Started'
                                  : 'Start Now',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final List<Color> gradient;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.gradient,
  });
}

class RoleSelectionSheet extends StatelessWidget {
  const RoleSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.getPadding(context),
      constraints: BoxConstraints(
        maxWidth: ResponsiveHelper.getMaxWidth(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Your Role',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (ResponsiveHelper.isMobile(context)) {
                return Column(
                  children: [
                    _RoleCard(
                      title: 'Restaurant',
                      icon: Icons.restaurant,
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              _AuthOptionsSheet(role: 'Restaurant'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: 'NGO',
                      icon: Icons.volunteer_activism,
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _AuthOptionsSheet(role: 'NGO'),
                        );
                      },
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'Restaurant',
                      icon: Icons.restaurant,
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              _AuthOptionsSheet(role: 'Restaurant'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleCard(
                      title: 'NGO',
                      icon: Icons.volunteer_activism,
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _AuthOptionsSheet(role: 'NGO'),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AuthOptionsSheet extends StatelessWidget {
  final String role;

  const _AuthOptionsSheet({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.getPadding(context),
      constraints: BoxConstraints(
        maxWidth: ResponsiveHelper.getMaxWidth(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome $role!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: ResponsiveHelper.isMobile(context) ? double.infinity : 300,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.isMobile(context) ? 16 : 20,
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: ResponsiveHelper.isMobile(context) ? double.infinity : 300,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  role == 'Restaurant' ? '/restaurant-signup' : '/ngo-signup',
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.isMobile(context) ? 16 : 20,
                ),
              ),
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: ResponsiveHelper.getPadding(context),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: ResponsiveHelper.isMobile(context)
                  ? 48
                  : ResponsiveHelper.isTablet(context)
                      ? 64
                      : 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
