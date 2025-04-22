import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Kindness/utils/responsive_helper.dart';

class NGOImpactReportScreen extends StatefulWidget {
  final String donationId;
  final String restaurantName;
  final String foodType;
  final int quantity;

  const NGOImpactReportScreen({
    Key? key,
    required this.donationId,
    required this.restaurantName,
    required this.foodType,
    required this.quantity,
  }) : super(key: key);

  @override
  State<NGOImpactReportScreen> createState() => _NGOImpactReportScreenState();
}

class _NGOImpactReportScreenState extends State<NGOImpactReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peopleFedController = TextEditingController();
  final _feedbackController = TextEditingController();
  final List<String> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _peopleFedController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPhotos.add(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getPaddingValue(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Impact Report'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donation Info
              Card(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Restaurant', widget.restaurantName),
                      _buildInfoRow('Food Type', widget.foodType),
                      _buildInfoRow('Quantity', '${widget.quantity} meals'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // People Fed
              TextFormField(
                controller: _peopleFedController,
                decoration: const InputDecoration(
                  labelText: 'Number of People Fed',
                  hintText: 'Enter the number of people who received food',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of people fed';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Feedback
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  hintText: 'Share your experience and impact',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide feedback';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Photo Gallery
              Text(
                'Photo Gallery',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPhotos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedPhotos.length) {
                      return _buildAddPhotoButton();
                    }
                    return _buildPhotoPreview(_selectedPhotos[index]);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Impact Metrics
              Text(
                'Impact Metrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildImpactMetric(
                'CO2 Saved',
                '${(widget.quantity * 0.5).toStringAsFixed(1)} kg',
                Icons.eco,
              ),
              _buildImpactMetric(
                'Food Waste Prevented',
                '${(widget.quantity * 0.3).toStringAsFixed(1)} kg',
                Icons.delete_outline,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement impact report submission
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Impact Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add Photo'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(String imagePath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedPhotos.remove(imagePath);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetric(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
