import 'package:flutter/material.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import 'package:Kindness/screens/restaurant/restaurant_profile_screen.dart';
import 'package:Kindness/screens/restaurant/post_donation_screen.dart';
import 'package:Kindness/screens/restaurant/active_donation_details_screen.dart';
import 'package:Kindness/screens/restaurant/donation_history_details_screen.dart';
import 'package:Kindness/screens/restaurant/impact_report_screen.dart';
import 'package:Kindness/screens/auth/login_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/api_service.dart';
import '../../models/restaurant.dart' as restaurant_model;
import '../../models/donation.dart';
import '../../theme/app_theme.dart';
import 'dart:async';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _error;
  restaurant_model.Restaurant? _restaurant;
  List<Donation> _recentDonations = [];
  List<Donation> _activeDonations = [];
  List<Donation> _historyDonations = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  final List<String> _carouselImages = [
    'assets/images/images.jpeg',
    'assets/images/download.jpeg',
    'assets/images/download (1).jpeg',
    'assets/images/467.jpg',
    'assets/images/images (1).jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRestaurantProfile();
    _fetchDonations();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        if (_currentPage < _carouselImages.length - 1) {
          _currentPage++;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
          );
        } else {
          // Reset to first image with a smooth transition
          _pageController
              .animateToPage(
            0,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
          )
              .then((_) {
            if (mounted) {
              setState(() {
                _currentPage = 0;
              });
            }
          });
        }
      }
    });
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
      // Reset the timer when user manually changes page
      _timer?.cancel();
      _startAutoScroll();
    }
  }

  Future<void> _fetchRestaurantProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profileData = await _apiService.getRestaurantProfile();
      if (mounted) {
        setState(() {
          _restaurant = restaurant_model.Restaurant.fromJson(profileData);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        print('Error fetching profile: $e');
      }
    }
  }

  Future<void> _fetchDonations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch recent donations
      final recentDonations =
          await _apiService.getRestaurantDonations(status: 'Completed');
      // Fetch active donations
      final activeDonations =
          await _apiService.getRestaurantDonations(status: 'Posted');
      // Fetch claimed donations
      final claimedDonations =
          await _apiService.getRestaurantDonations(status: 'Claimed');

      if (!mounted) return;

      setState(() {
        _recentDonations = recentDonations;
        _activeDonations = activeDonations;
        _historyDonations = claimedDonations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching donations: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Error fetching donations: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching donations: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    // Navigate to login screen and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Home'
              : _selectedIndex == 1
                  ? 'Active'
                  : _selectedIndex == 2
                      ? 'Claimed'
                      : 'Profile',
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(),
          _buildActiveDonationsScreen(),
          _buildHistoryScreen(),
          _buildProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Claimed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostDonationScreen(),
            ),
          ).then((_) => _fetchDonations());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Impact Card
          _buildImpactCard(),
          SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),

          // Carousel Section
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _carouselImages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(_carouselImages[index]),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Page Indicators
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _carouselImages.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Food Safety Tips Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.eco, color: AppTheme.accentColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Food Waste Prevention',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFoodSafetyTipCard(
                  icon: Icons.inventory_2,
                  title: 'Inventory Management',
                  description:
                      'Regularly check stock and rotate items using FIFO method',
                ),
                _buildFoodSafetyTipCard(
                  icon: Icons.refresh,
                  title: 'Creative Reuse',
                  description:
                      'Transform surplus ingredients into new menu items',
                ),
                _buildFoodSafetyTipCard(
                  icon: Icons.local_shipping,
                  title: 'Timely Donations',
                  description:
                      'Donate excess food before it reaches expiry date',
                ),
                _buildFoodSafetyTipCard(
                  icon: Icons.eco,
                  title: 'Composting',
                  description: 'Compost food scraps that can\'t be donated',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSafetyTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.softGradient,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
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
                  description,
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

  Widget _buildImpactCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getPaddingValue(context),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding:
              EdgeInsets.all(ResponsiveHelper.getPaddingValue(context) * 1.2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.primaryGradient,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: ResponsiveHelper.isMobile(context) ? 24 : 28,
                  ),
                  SizedBox(
                      width: ResponsiveHelper.getPaddingValue(context) * 0.8),
                  Text(
                    'Your Impact',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),
              Wrap(
                spacing: ResponsiveHelper.getPaddingValue(context) * 0.8,
                runSpacing: ResponsiveHelper.getPaddingValue(context) * 0.8,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  _buildImpactStat(
                    context,
                    icon: Icons.restaurant,
                    label: 'Meals Donated',
                    value: '150',
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
                    value: '75 kg',
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
                    label: 'People Fed',
                    value: '120',
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
        ),
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
        horizontal: ResponsiveHelper.getPaddingValue(context) * 0.8,
        vertical: ResponsiveHelper.getPaddingValue(context) * 0.6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: ResponsiveHelper.isMobile(context) ? 24 : 28,
            color: color,
          ),
          SizedBox(height: ResponsiveHelper.getHeight(context) * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 12),
              color: color.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDonations() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_recentDonations.isEmpty) {
      return const Center(
        child: Text('No recent donations'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentDonations.length,
      itemBuilder: (context, index) {
        final donation = _recentDonations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.restaurant),
            ),
            title: Text(donation.foodType),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${donation.quantity} meals'),
                Text('Pickup: ${_formatDateTime(donation.pickupDeadline)}'),
                if (donation.allergens.isNotEmpty)
                  Text('Allergens: ${donation.allergens.join(", ")}'),
              ],
            ),
            trailing: _buildStatusChip(donation.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DonationHistoryDetailsScreen(
                    donationId: donation.id,
                    foodImage:
                        donation.images.isNotEmpty ? donation.images[0] : '',
                    status: donation.status,
                    quantity: donation.quantity,
                    allergens: donation.allergens,
                    ngoName: donation.restaurantId.name,
                    ngoContact: donation.restaurantId.address.street,
                    ngoFeedbacks: const [],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveDonationsScreen() {
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
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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

    if (_activeDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 64,
                color: Colors.orange[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No active donations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create a new donation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeDonations.length,
        itemBuilder: (context, index) {
          final donation = _activeDonations[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                      builder: (context) => ActiveDonationDetailsScreen(
                        donationId: donation.id,
                        foodImage: donation.images.isNotEmpty
                            ? donation.images[0]
                            : '',
                        status: donation.status,
                        quantity: int.parse(donation.quantity),
                        allergens: donation.allergens,
                        restaurantLocation: const LatLng(0, 0),
                        ngoLocation: const LatLng(0, 0),
                        ngoName: donation.restaurantId.name,
                        ngoContact: donation.restaurantId.address.street,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Image Section
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          // Food Image with shimmer effect
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            child: donation.images.isNotEmpty
                                ? Image.network(
                                    donation.images[0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.restaurant,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Status Badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_shipping,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Type and Quantity
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  donation.foodType,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${donation.quantity} meals',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Pickup Deadline
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pickup by ${_formatDateTime(donation.pickupDeadline)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (donation.allergens.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 20,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Contains: ${donation.allergens.join(", ")}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryScreen() {
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
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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

    if (_historyDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No claimed donations yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Donations claimed by NGOs will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDonations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyDonations.length,
        itemBuilder: (context, index) {
          final donation = _historyDonations[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                      builder: (context) => DonationHistoryDetailsScreen(
                        donationId: donation.id,
                        foodImage: donation.images.isNotEmpty
                            ? donation.images[0]
                            : '',
                        status: donation.status,
                        quantity: donation.quantity,
                        allergens: donation.allergens,
                        ngoName: donation.claimedBy?.name ?? '',
                        ngoContact: donation.claimedBy?.contact ?? '',
                        ngoFeedbacks: const [],
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Image Section
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          // Food Image with shimmer effect
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            child: donation.images.isNotEmpty
                                ? Image.network(
                                    donation.images[0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.restaurant,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Status Badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Claimed',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Type and Quantity
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  donation.foodType,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 16,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${donation.quantity} meals',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (donation.allergens.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 20,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Contains: ${donation.allergens.join(", ")}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Posted':
        chipColor = Colors.orange;
        break;
      case 'Claimed':
        chipColor = Colors.blue;
        break;
      case 'Completed':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildProfileScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRestaurantProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RestaurantProfileScreen(
      restaurant: _restaurant ??
          restaurant_model.Restaurant(
            id: '',
            name: 'Loading...',
            email: '',
            phone: '',
            taxId: '',
            address: {},
            serviceArea: {},
          ),
    );
  }
}
