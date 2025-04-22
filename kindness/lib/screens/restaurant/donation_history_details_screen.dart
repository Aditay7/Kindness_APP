import 'package:flutter/material.dart';
import 'package:Kindness/theme/app_theme.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/donation.dart';
import '../../services/api_service.dart';

class DonationHistoryDetailsScreen extends StatefulWidget {
  final String donationId;
  final String foodImage;
  final String status;
  final String quantity;
  final List<String> allergens;
  final String ngoName;
  final String ngoContact;
  final List<String> ngoFeedbacks;

  const DonationHistoryDetailsScreen({
    Key? key,
    required this.donationId,
    required this.foodImage,
    required this.status,
    required this.quantity,
    required this.allergens,
    required this.ngoName,
    required this.ngoContact,
    required this.ngoFeedbacks,
  }) : super(key: key);

  @override
  State<DonationHistoryDetailsScreen> createState() =>
      _DonationHistoryDetailsScreenState();
}

class _DonationHistoryDetailsScreenState
    extends State<DonationHistoryDetailsScreen> {
  final ApiService _apiService = ApiService();
  Donation? _donation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDonationDetails();
  }

  Future<void> _fetchDonationDetails() async {
    try {
      // Instead of fetching donation details, we'll use the data passed to the screen
      // This avoids the permission issue with the API
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Image
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(widget.foodImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.status == 'Claimed'
                              ? Colors.blue
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
                      const SizedBox(height: 16),

                      // Food Details
                      _buildSection(
                        title: 'Food Details',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${widget.quantity} meals'),
                            if (widget.allergens.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Allergens: ${widget.allergens.join(", ")}'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // NGO Details (if claimed)
                      if (widget.status == 'Claimed' &&
                          widget.ngoName.isNotEmpty) ...[
                        _buildSection(
                          title: 'Claimed by NGO',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ngoName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (widget.ngoContact.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 20),
                                    const SizedBox(width: 8),
                                    Text(widget.ngoContact),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Feedback Section
                      if (widget.ngoFeedbacks.isNotEmpty) ...[
                        _buildSection(
                          title: 'NGO Feedback',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.ngoFeedbacks.map((feedback) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text('• $feedback'),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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
