import 'package:flutter/material.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import 'package:Kindness/screens/ngo/ngo_profile_screen.dart';
import 'package:Kindness/screens/ngo/track_pickup_screen.dart';
import 'package:Kindness/screens/ngo/donation_details_screen.dart';
import 'package:Kindness/screens/auth/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:Kindness/services/api_service.dart';
import 'package:Kindness/models/ngo.dart';
import 'package:Kindness/models/donation.dart' as donation_model;
import '../../theme/app_theme.dart';
import 'dart:async';
import 'package:Kindness/screens/ngo/ngo_donation_details_screen.dart';
import '../../services/notification_service.dart';
import 'dart:math' as math;

class NGODashboardScreen extends StatefulWidget {
  const NGODashboardScreen({Key? key}) : super(key: key);

  @override
  State<NGODashboardScreen> createState() => _NGODashboardScreenState();
}

class _NGODashboardScreenState extends State<NGODashboardScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  Timer? _refreshTimer;
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _error;
  NGO? _ngo;
  List<donation_model.Donation> _availableDonations = [];
  List<donation_model.Donation> _activeClaims = [];
  late PageController _pageController;
  int _currentPage = 0;
  List<String> _carouselImages = [
    'assets/images/carousel1.jpg',
    'assets/images/carousel2.jpg',
    'assets/images/carousel3.jpg',
  ];
  List<donation_model.Donation> _recentDonations = [];

  // Dashboard statistics
  Map<String, dynamic> _dashboardStats = {
    'mealsDistributed': 0,
    'beneficiaries': 0,
    'areasServed': 0,
    'co2Saved': 0,
    'peopleFed': 0,
  };
  List<Map<String, dynamic>> _monthlyImpact = [];
  bool _isLoadingStats = false;
  String? _statsError;

  // Global food waste statistics
  Map<String, dynamic> _globalFoodWasteStats = {
    'globalWaste': {'amount': '0', 'description': ''},
    'peopleAffected': {'amount': '0', 'description': ''},
    'environmentalImpact': {'amount': '0', 'description': ''},
  };
  bool _isLoadingGlobalStats = false;
  String? _globalStatsError;

  // Static data for active pickups
  final List<Map<String, dynamic>> _activePickups = [
    {
      'id': '3',
      'restaurantName': 'Fresh Foods',
      'foodType': 'Mixed',
      'quantity': '20 meals',
      'status': 'On the way',
      'eta': '5 mins',
      'imageUrl': 'https://example.com/food3.jpg',
      'restaurantAddress': '789 Food Street',
      'volunteerName': 'John Doe',
      'volunteerPhone': '+1234567890',
      'restaurantPhone': '+0987654321',
      'estimatedArrivalTime': '2024-04-02T15:30:00Z',
    },
    {
      'id': '4',
      'restaurantName': 'Healthy Bites',
      'foodType': 'Vegetarian',
      'quantity': '25 meals',
      'status': 'Pickup scheduled',
      'eta': '2:00 PM',
      'imageUrl': 'https://example.com/food4.jpg',
      'restaurantAddress': '321 Food Street',
      'volunteerName': 'Jane Smith',
      'volunteerPhone': '+1122334455',
      'restaurantPhone': '+5566778899',
      'estimatedArrivalTime': '2024-04-02T14:00:00Z',
    },
  ];

  // Static data for donation history
  final List<Map<String, dynamic>> _donationHistory = [
    {
      'id': '5',
      'restaurantName': 'Fresh Foods',
      'foodType': 'Mixed',
      'quantity': '30 meals',
      'date': 'Mar 30, 2024',
      'status': 'Completed',
      'peopleFed': 25,
      'imageUrl': 'https://example.com/food5.jpg',
    },
    {
      'id': '6',
      'restaurantName': 'Healthy Bites',
      'foodType': 'Vegetarian',
      'quantity': '20 meals',
      'date': 'Mar 29, 2024',
      'status': 'Completed',
      'peopleFed': 18,
      'imageUrl': 'https://example.com/food6.jpg',
    },
  ];

  // Static data for impact stats
  final Map<String, dynamic> _impactStats = {
    'mealsDelivered': 150,
    'co2Saved': '75 kg',
    'peopleFed': 120,
  };

  @override
  void initState() {
    super.initState();
    _fetchNGOProfile();
    _fetchAvailableDonations();
    _fetchActiveClaims();
    _fetchDashboardData();
    _pageController = PageController();
    _startAutoRefresh();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStats = true;
      _statsError = null;
      _isLoadingGlobalStats = true;
      _globalStatsError = null;
    });

    try {
      final stats = await _apiService.getNGODashboardStats();
      final monthlyImpact = await _apiService.getNGOMonthlyImpact();
      final globalStats = await _apiService.getGlobalFoodWasteStats();

      if (!mounted) return;

      setState(() {
        _dashboardStats = stats;
        _monthlyImpact = monthlyImpact;
        _globalFoodWasteStats = globalStats;
        _isLoadingStats = false;
        _isLoadingGlobalStats = false;
      });

      // Show a snackbar to indicate data refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard data refreshed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error fetching dashboard data: $e');
      if (!mounted) return;

      setState(() {
        _statsError = e.toString();
        _isLoadingStats = false;
        _isLoadingGlobalStats = false;
      });

      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing data: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startAutoRefresh() {
    // Refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_selectedIndex == 0) {
        // Refresh dashboard data when on Home tab
        _fetchDashboardData();
      } else if (_selectedIndex == 1) {
        // Active tab
        _fetchAvailableDonations();
      } else if (_selectedIndex == 2) {
        // Active Claims tab
        _fetchActiveClaims();
      }
    });
  }

  Future<void> _fetchNGOProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First check if user is logged in
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('Please log in to view your profile');
      }

      // Then check if user is an NGO
      final userType = await _apiService.getUserType();
      if (userType != 'ngo') {
        throw Exception('Access denied. User is not an NGO.');
      }

      print('Fetching NGO profile...');
      final ngo = await _apiService.getNGOProfile();
      print('Successfully fetched NGO profile: ${ngo.name}');

      if (!mounted) return;

      setState(() {
        _ngo = ngo;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching NGO profile: $e');
      if (!mounted) return;

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });

      // If the error is about session expiry or invalid token, show a dialog
      if (errorMessage.contains('session expired') ||
          errorMessage.contains('authentication token') ||
          errorMessage.contains('Please log in')) {
        if (!mounted) return;
        _showSessionExpiredDialog();
      }
    }
  }

  Future<void> _fetchAvailableDonations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First check if user is logged in
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('Please log in to view available donations');
      }

      // Then check if user is an NGO
      final userType = await _apiService.getUserType();
      print('Current user type: $userType'); // Debug print

      if (userType != 'ngo') {
        throw Exception(
            'Access denied. Only NGOs can view available donations.');
      }

      print('Starting to fetch available donations...'); // Debug print
      final donations = await _apiService.getAvailableDonations();
      print(
          'Successfully fetched ${donations.length} donations'); // Debug print

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _availableDonations = donations;
      });
    } catch (e) {
      print('Error fetching available donations: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });

      // Show appropriate error message based on the error type
      if (e.toString().contains('session expired') ||
          e.toString().contains('Please log in')) {
        _showSessionExpiredDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error ?? 'Error fetching donations'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchAvailableDonations,
              textColor: Colors.white,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _fetchActiveClaims() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final claims = await _apiService.getDonations();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _activeClaims = claims;
        // Sort by newest first
        _activeClaims.sort((a, b) => b.claimedAt!.compareTo(a.claimedAt!));
      });
    } catch (e) {
      print('Error fetching active claims: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception:', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error ?? 'Error fetching active claims'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchActiveClaims,
            textColor: Colors.white,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        // Active tab
        _fetchAvailableDonations(); // Refresh when switching to Active tab
      } else if (index == 2) {
        // Active Claims tab
        _fetchActiveClaims(); // Refresh when switching to Active Claims tab
      }
    });
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Impact Card with Graph
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _buildImpactCard(),
          ),
          SizedBox(height: ResponsiveHelper.getHeight(context) * 0.03),

          // Global Food Waste Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.analytics,
                          color: AppTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Global Food Waste Statistics',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 22),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatCard(
                  icon: Icons.delete_outline,
                  title: 'Global Food Waste',
                  value: '1.3 billion tons',
                  subtitle: 'of food is wasted annually',
                  color: AppTheme.primaryColor,
                ),
                _buildStatCard(
                  icon: Icons.people_outline,
                  title: 'People Affected',
                  value: '811 million',
                  subtitle: 'people go hungry worldwide',
                  color: AppTheme.accentColor,
                ),
                _buildStatCard(
                  icon: Icons.eco,
                  title: 'Environmental Impact',
                  value: '8-10%',
                  subtitle: 'of global greenhouse gas emissions',
                  color: AppTheme.emotionalColor,
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getHeight(context) * 0.03),

          // Monthly Impact Bar Chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.bar_chart,
                          color: AppTheme.accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Monthly Impact',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 22),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMonthlyImpactChart(),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getHeight(context) * 0.03),

          // NGO Impact & Guidelines
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.volunteer_activism,
                          color: Colors.blue[700], size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Impact & Guidelines',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 22),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildGuidelineCard(
                  icon: Icons.safety_check,
                  title: 'Food Safety Protocol',
                  description:
                      'Verify food quality, temperature, and packaging before distribution',
                ),
                _buildGuidelineCard(
                  icon: Icons.people,
                  title: 'Beneficiary Tracking',
                  description:
                      'Maintain digital records of beneficiaries and their needs',
                ),
                _buildGuidelineCard(
                  icon: Icons.local_shipping,
                  title: 'Smart Distribution',
                  description:
                      'Optimize routes and schedules for maximum impact',
                ),
                _buildGuidelineCard(
                  icon: Icons.analytics,
                  title: 'Impact Measurement',
                  description:
                      'Track and report your contribution to reducing food waste',
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getHeight(context) * 0.03),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard() {
    // Static data for impact statistics
    final Map<String, dynamic> staticStats = {
      'mealsDistributed': 215,
      'beneficiaries': 180,
      'areasServed': 8,
      'co2Saved': 85,
      'peopleFed': 180,
    };

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getPaddingValue(context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getPaddingValue(context) * 1.2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getPaddingValue(context) * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: ResponsiveHelper.isMobile(context) ? 24 : 28,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getPaddingValue(context) * 0.8),
              Text(
                'Your Impact',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getHeight(context) * 0.04),
          Wrap(
            spacing: ResponsiveHelper.getPaddingValue(context),
            runSpacing: ResponsiveHelper.getPaddingValue(context),
            alignment: WrapAlignment.spaceEvenly,
            children: [
              _buildImpactStat(
                context,
                icon: Icons.restaurant,
                label: 'Meals',
                value: staticStats['mealsDistributed'].toString(),
                color: Colors.black87,
                gradient: [
                  const Color(0xFFFFF59D),
                  const Color(0xFFFFF176),
                  const Color(0xFFFFEE58)
                ],
              ),
              _buildImpactStat(
                context,
                icon: Icons.people,
                label: 'Beneficiaries',
                value: staticStats['beneficiaries'].toString(),
                color: Colors.black87,
                gradient: [
                  const Color(0xFFFFF59D),
                  const Color(0xFFFFF176),
                  const Color(0xFFFFEE58)
                ],
              ),
              _buildImpactStat(
                context,
                icon: Icons.location_on,
                label: 'Areas',
                value: staticStats['areasServed'].toString(),
                color: Colors.black87,
                gradient: [
                  const Color(0xFFFFF59D),
                  const Color(0xFFFFF176),
                  const Color(0xFFFFEE58)
                ],
              ),
              _buildImpactStat(
                context,
                icon: Icons.eco,
                label: 'CO2 Saved',
                value: '${staticStats['co2Saved']} kg',
                color: Colors.black87,
                gradient: [
                  const Color(0xFFFFF59D),
                  const Color(0xFFFFF176),
                  const Color(0xFFFFEE58)
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getPaddingValue(context) * 1.2,
        vertical: ResponsiveHelper.getPaddingValue(context) * 0.8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                EdgeInsets.all(ResponsiveHelper.getPaddingValue(context) * 0.6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveHelper.isMobile(context) ? 22 : 26,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getPaddingValue(context) * 0.8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: color.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildRecentDonationsList() {
    if (_recentDonations.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recent donations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentDonations.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final donation = _recentDonations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange[100],
              child: Icon(Icons.restaurant, color: Colors.orange[700]),
            ),
            title: Text(donation.foodType),
            subtitle: Text('${donation.quantity} meals available'),
            trailing: _buildStatusChip(donation.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NGODonationDetailsScreen(
                    donationId: donation.id,
                    foodImage:
                        donation.images.isNotEmpty ? donation.images[0] : '',
                    foodType: donation.foodType,
                    quantity: int.parse(donation.quantity),
                    restaurantName: donation.restaurantId.name,
                    restaurantAddress: donation.restaurantId.address.street,
                    restaurantRating: 4.5,
                    pickupDeadline: donation.pickupDeadline,
                    allergens: donation.allergens,
                    restaurantPhone: donation.restaurantId.phone,
                    status: donation.status,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'Claimed':
        color = Colors.blue;
        label = 'Claimed';
        break;
      case 'On the way':
        color = Colors.orange;
        label = 'On the way';
        break;
      case 'Pickup scheduled':
        color = Colors.green;
        label = 'Pickup scheduled';
        break;
      case 'Completed':
        color = Colors.grey;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.softGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          _selectedIndex == 0
              ? 'Home'
              : _selectedIndex == 1
                  ? 'Available'
                  : _selectedIndex == 2
                      ? 'Active Claims'
                      : 'Profile',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(),
          _buildActivePickupsScreen(),
          _buildActiveClaimsScreen(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Available',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Active Claims',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildActivePickupsScreen() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.error_outline,
                  size: 48, color: AppTheme.errorColor),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchAvailableDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_availableDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.no_food, size: 64, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'No available donations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new donations',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAvailableDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAvailableDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableDonations.length,
        itemBuilder: (context, index) {
          final donation = _availableDonations[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NGODonationDetailsScreen(
                        donationId: donation.id,
                        foodImage: donation.images.isNotEmpty
                            ? donation.images[0]
                            : '',
                        foodType: donation.foodType,
                        quantity: int.parse(donation.quantity),
                        restaurantName: donation.restaurantId.name,
                        restaurantAddress: donation.restaurantId.address.street,
                        restaurantRating: 4.5,
                        pickupDeadline: donation.pickupDeadline,
                        allergens: donation.allergens,
                        restaurantPhone: donation.restaurantId.phone,
                        status: donation.status,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (donation.images.isNotEmpty)
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      donation.images[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.restaurantId.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: const Color(0xFF666666),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        donation.restaurantId.address.street,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppTheme.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${donation.quantity} meals',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: const Color(0xFF666666)),
                          const SizedBox(width: 4),
                          Text(
                            'Pickup by ${_formatDateTime(donation.pickupDeadline)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await _apiService.claimDonation(donation.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Donation claimed successfully!'),
                                    backgroundColor: Color(0xFF2E7D32),
                                  ),
                                );
                                _fetchAvailableDonations();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error claiming donation: $e'),
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline,
                                size: 16),
                            label: const Text('Claim',
                                style: TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                      if (donation.allergens.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: donation.allergens.map((allergen) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6F61).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 12,
                                    color: const Color(0xFFFF6F61),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    allergen,
                                    style: const TextStyle(
                                      color: Color(0xFFFF6F61),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveClaimsScreen() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.error_outline,
                  size: 48, color: AppTheme.errorColor),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchActiveClaims,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_activeClaims.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No active claims',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Claims you make will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchActiveClaims,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeClaims.length,
        itemBuilder: (context, index) {
          final donation = _activeClaims[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NGODonationDetailsScreen(
                        donationId: donation.id,
                        foodImage: donation.images.isNotEmpty
                            ? donation.images[0]
                            : '',
                        foodType: donation.foodType,
                        quantity: int.parse(donation.quantity),
                        restaurantName: donation.restaurantId.name,
                        restaurantAddress: donation.restaurantId.address.street,
                        restaurantRating: 4.5,
                        pickupDeadline: donation.pickupDeadline,
                        allergens: donation.allergens,
                        restaurantPhone: donation.restaurantId.phone,
                        status: donation.status,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (donation.images.isNotEmpty)
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      donation.images[0]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.restaurantId.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: const Color(0xFF666666),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        donation.restaurantId.address.street,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppTheme.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${donation.quantity} meals',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: const Color(0xFF666666)),
                          const SizedBox(width: 4),
                          Text(
                            'Pickup by ${_formatDateTime(donation.pickupDeadline)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackPickupScreen(
                                    donationId: donation.id,
                                    restaurantName: donation.restaurantId.name,
                                    restaurantAddress:
                                        donation.restaurantId.address.street,
                                    restaurantPhone:
                                        donation.restaurantId.phone,
                                    volunteerName: "John Doe",
                                    volunteerPhone: "+1234567890",
                                    estimatedArrivalTime: DateTime.now()
                                        .add(const Duration(hours: 1)),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.location_on, size: 16),
                            label: const Text('Track',
                                style: TextStyle(fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                      if (donation.allergens.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: donation.allergens.map((allergen) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6F61).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 12,
                                    color: const Color(0xFFFF6F61),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    allergen,
                                    style: const TextStyle(
                                      color: Color(0xFFFF6F61),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNGOProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_ngo == null) {
      return const Center(
        child: Text('No profile data available'),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppTheme.primaryGradient,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        _ngo!.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _ngo!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(
                  icon: Icons.business,
                  title: 'Registration Details',
                  content:
                      Text('Registration Number: ${_ngo!.registrationNumber}'),
                ),
                const SizedBox(height: 16),
                _buildProfileCard(
                  icon: Icons.contact_mail,
                  title: 'Contact Information',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_ngo!.email),
                      Text(_ngo!.phone),
                      Text(
                          '${_ngo!.address['street']}, ${_ngo!.address['city']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileCard(
                  icon: Icons.restaurant,
                  title: 'Food Preferences',
                  content: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ngo!.preferredFoodTypes.map((type) {
                      return Chip(
                        label: Text(type),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _apiService.logout();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error logging out: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      content,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Widget _buildMonthlyImpactChart() {
    final isMobile = ResponsiveHelper.isMobile(context);
    final chartHeight = isMobile ? 200.0 : 300.0;
    final barWidth = isMobile ? 20.0 : 30.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun'
                        ];
                        if (value >= 0 && value < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textSecondaryColor.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 65, AppTheme.primaryColor),
                  _makeBarGroup(1, 75, AppTheme.primaryColor),
                  _makeBarGroup(2, 85, AppTheme.primaryColor),
                  _makeBarGroup(3, 70, AppTheme.primaryColor),
                  _makeBarGroup(4, 90, AppTheme.primaryColor),
                  _makeBarGroup(5, 80, AppTheme.primaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Monthly Food Donation Impact',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: ResponsiveHelper.isMobile(context) ? 20 : 30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
