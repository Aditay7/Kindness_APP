import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Kindness/theme/app_theme.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ActiveDonationDetailsScreen extends StatefulWidget {
  final String donationId;
  final String foodImage;
  final String status;
  final int quantity;
  final List<String> allergens;
  final String ngoName;
  final String ngoContact;
  final LatLng restaurantLocation;
  final LatLng ngoLocation;

  const ActiveDonationDetailsScreen({
    super.key,
    required this.donationId,
    required this.foodImage,
    required this.status,
    required this.quantity,
    required this.allergens,
    required this.ngoName,
    required this.ngoContact,
    required this.restaurantLocation,
    required this.ngoLocation,
  });

  @override
  State<ActiveDonationDetailsScreen> createState() =>
      _ActiveDonationDetailsScreenState();
}

class _ActiveDonationDetailsScreenState
    extends State<ActiveDonationDetailsScreen> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    _markers = {
      Marker(
        markerId: const MarkerId('restaurant'),
        position: widget.restaurantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Restaurant'),
      ),
      Marker(
        markerId: const MarkerId('ngo'),
        position: widget.ngoLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: widget.ngoName),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              // TODO: Implement chat functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image with error handling
            Container(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.foodImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.status == 'Claimed'
                            ? Colors.orange
                            : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: ResponsiveHelper.getPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Quantity and Allergens
                  Row(
                    children: [
                      _buildInfoCard(
                        icon: Icons.people,
                        title: 'Quantity',
                        value: 'Feeds ${widget.quantity} people',
                      ),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                        icon: Icons.warning,
                        title: 'Allergens',
                        value: widget.allergens.join(', '),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // NGO Contact Info
                  _buildSection(
                    title: 'NGO Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ngoName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 20),
                            const SizedBox(width: 8),
                            Text(widget.ngoContact),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Map Section
                  _buildSection(
                    title: 'Pickup Location',
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Location: ${widget.restaurantLocation.latitude}, ${widget.restaurantLocation.longitude}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement mark as completed functionality
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Mark as Completed'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
