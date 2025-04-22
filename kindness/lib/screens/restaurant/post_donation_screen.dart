import 'package:flutter/material.dart';
// import 'package:Kindness/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../models/donation.dart';

class PostDonationScreen extends StatefulWidget {
  const PostDonationScreen({Key? key}) : super(key: key);

  @override
  State<PostDonationScreen> createState() => _PostDonationScreenState();
}

class _PostDonationScreenState extends State<PostDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  String? _error;
  String? _selectedFoodType;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _pickupDeadlineController = TextEditingController();
  File? _foodImage;
  DateTime _pickupDeadline = DateTime.now().add(const Duration(hours: 2));
  final List<String> _selectedAllergens = [];

  final List<String> _foodTypes = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Halal',
    'Kosher',
  ];

  final List<String> _allergens = [
    'Nuts',
    'Dairy',
    'Eggs',
    'Soy',
    'Wheat',
    'Fish',
    'Shellfish',
    'None',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _foodImage = File(image.path);
      });
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _pickupDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_pickupDeadline),
      );
      if (time != null) {
        setState(() {
          _pickupDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _pickupDeadlineController.text =
              '${_pickupDeadline.day}/${_pickupDeadline.month}/${_pickupDeadline.year} ${_pickupDeadline.hour}:${_pickupDeadline.minute.toString().padLeft(2, '0')}';
        });
      }
    }
  }

  void _toggleAllergen(String allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
      }
    });
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final donation = await _apiService.createDonation(
        foodType: _selectedFoodType!,
        quantity: int.parse(_quantityController.text),
        allergens: _selectedAllergens,
        pickupDeadline: _pickupDeadline,
        additionalNote: _notesController.text,
        imageFile: _foodImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation posted successfully!')),
      );

      Navigator.pop(context, donation);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pickupDeadlineController.text =
        '${_pickupDeadline.day}/${_pickupDeadline.month}/${_pickupDeadline.year} ${_pickupDeadline.hour}:${_pickupDeadline.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Donation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _foodImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _foodImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Food Type',
                  border: OutlineInputBorder(),
                ),
                items: _foodTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a food type';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedFoodType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity (in meals)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Allergens',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allergens.map((allergen) {
                  return FilterChip(
                    label: Text(allergen),
                    selected: _selectedAllergens.contains(allergen),
                    onSelected: (selected) {
                      _toggleAllergen(allergen);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pickup Deadline',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: _selectDateTime,
                controller: _pickupDeadlineController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select pickup deadline';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitDonation,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Post Donation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _pickupDeadlineController.dispose();
    super.dispose();
  }
}
