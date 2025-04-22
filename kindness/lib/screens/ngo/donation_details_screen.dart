import 'package:flutter/material.dart';
import 'package:Kindness/theme/app_theme.dart';
import 'package:Kindness/utils/responsive_helper.dart';

class DonationDetailsScreen extends StatefulWidget {
  final String donationId;
  final String foodImage;
  final String foodType;
  final int quantity;
  final List<String> allergens;
  final String restaurantName;
  final String restaurantAddress;
  final double restaurantRating;
  final DateTime pickupDeadline;

  const DonationDetailsScreen({
    super.key,
    required this.donationId,
    required this.foodImage,
    required this.foodType,
    required this.quantity,
    required this.allergens,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantRating,
    required this.pickupDeadline,
  });

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _selectedPickupTime;

  void _showPickupSchedulingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Pickup',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                // Pickup Time Selection
                ListTile(
                  title: const Text('Pickup Time'),
                  subtitle: Text(
                    _selectedPickupTime != null
                        ? '${_selectedPickupTime!.hour}:${_selectedPickupTime!.minute}'
                        : 'Select time',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedPickupTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Volunteer Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Volunteer Notes',
                    hintText: 'Add any special instructions',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedPickupTime != null) {
                        // TODO: Implement pickup scheduling
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirm Pickup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            // Food Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.foodImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: ResponsiveHelper.getPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Food Details
                  Row(
                    children: [
                      _buildInfoCard(
                        icon: Icons.restaurant,
                        title: 'Food Type',
                        value: widget.foodType,
                      ),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                        icon: Icons.people,
                        title: 'Quantity',
                        value: 'Feeds ${widget.quantity} people',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.warning,
                    title: 'Allergens',
                    value: widget.allergens.join(', '),
                  ),
                  const SizedBox(height: 24),
                  // Restaurant Info
                  _buildSection(
                    title: 'Restaurant Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.restaurantName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.restaurantRating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(widget.restaurantAddress)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showPickupSchedulingModal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Claim Donation'),
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
