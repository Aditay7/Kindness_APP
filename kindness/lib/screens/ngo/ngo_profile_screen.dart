import 'package:flutter/material.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import '../../models/ngo.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class NGOProfileScreen extends StatelessWidget {
  final NGO ngo;
  final ApiService _apiService = ApiService();

  NGOProfileScreen({
    Key? key,
    required this.ngo,
  }) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _apiService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ngo.id.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.all(ResponsiveHelper.getWidth(context) * 0.05),
              child: Column(
                children: [
                  _buildProfileCard(context),
                  SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),
                  _buildContactCard(context),
                  SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),
                  _buildFoodPreferencesCard(context),
                  SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),
                  _buildLogoutButton(context),
                  SizedBox(height: ResponsiveHelper.getHeight(context) * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: ResponsiveHelper.getHeight(context) * 0.25,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  ngo.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getHeight(context) * 0.01),
              Text(
                ngo.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                ngo.registrationNumber,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getWidth(context) * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.volunteer_activism,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getWidth(context) * 0.02),
                Text(
                  'NGO Profile',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),
            _buildInfoRow(Icons.badge,
                'Registration: ${ngo.registrationNumber}', context),
            _buildInfoRow(Icons.email, ngo.email, context),
            _buildInfoRow(Icons.phone, ngo.phone, context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getWidth(context) * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getWidth(context) * 0.02),
                Text(
                  'Address',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),
            Text(
              _formatAddress(ngo.address),
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodPreferencesCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getWidth(context) * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getWidth(context) * 0.02),
                Text(
                  'Food Preferences',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getHeight(context) * 0.02),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ngo.preferredFoodTypes.map((type) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getWidth(context) * 0.03,
                    vertical: ResponsiveHelper.getHeight(context) * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                      SizedBox(
                          width: ResponsiveHelper.getWidth(context) * 0.01),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getHeight(context) * 0.01),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: ResponsiveHelper.getWidth(context) * 0.03),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getHeight(context) * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    return '${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['zipCode'] ?? ''}';
  }
}
