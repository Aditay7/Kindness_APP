import 'package:flutter/material.dart';
import 'package:Kindness/screens/ngo/ngo_dashboard_screen.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NGOSignupScreen extends StatefulWidget {
  const NGOSignupScreen({super.key});

  @override
  State<NGOSignupScreen> createState() => _NGOSignupScreenState();
}

class _NGOSignupScreenState extends State<NGOSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final List<String> _preferredFoodTypes = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _apiService = ApiService();
  String? _selectedNGOType;

  final List<String> _ngoTypes = [
    'Homeless Shelter',
    'Animal Rescue',
    'Food Bank',
    'Community Kitchen',
    'Youth Center',
    'Senior Center',
    'Other',
  ];

  final List<String> _availableFoodTypes = [
    'Vegetarian',
    'Non-Vegetarian',
    'Mixed',
  ];

  Future<void> _pickImage() async {
    // Removed image picker functionality
  }

  void _toggleFoodType(String type) {
    setState(() {
      if (_preferredFoodTypes.contains(type)) {
        _preferredFoodTypes.remove(type);
      } else {
        _preferredFoodTypes.add(type);
      }
    });
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedNGOType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an NGO type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: 'ngo',
        phone: _phoneController.text.trim(),
        address: {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'country': _countryController.text.trim(),
        },
        registrationNumber: _registrationNumberController.text.trim(),
        preferredFoodTypes: _preferredFoodTypes,
        ngoType: _selectedNGOType!,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/ngo-dashboard');
      }
    } catch (e) {
      print('Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.glowGradient,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: ResponsiveHelper.getPadding(context),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.getMaxWidth(context),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.05,
                          ),
                          Text(
                            'NGO Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveHelper.getFontSize(context, 24),
                                  color: AppTheme.textPrimaryColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.03,
                          ),
                          _buildTextField(
                            controller: _nameController,
                            label: 'NGO Name',
                            icon: Icons.volunteer_activism,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter NGO name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _streetController,
                            label: 'Street Address',
                            icon: Icons.location_on,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter street address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter city';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _stateController,
                            label: 'State',
                            icon: Icons.map,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter state';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _countryController,
                            label: 'Country',
                            icon: Icons.public,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter country';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          _buildTextField(
                            controller: _registrationNumberController,
                            label: 'Registration Number',
                            icon: Icons.numbers,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter registration number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          // NGO Type Selection
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppTheme.neutralGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NGO Type',
                                  style: TextStyle(
                                    color: AppTheme.textPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _ngoTypes.map((type) {
                                    return FilterChip(
                                      label: Text(type),
                                      selected: _selectedNGOType == type,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedNGOType =
                                              selected ? type : null;
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      selectedColor: AppTheme.primaryColor,
                                      labelStyle: TextStyle(
                                        color: _selectedNGOType == type
                                            ? Colors.white
                                            : AppTheme.textPrimaryColor,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                          // Preferred Food Types
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppTheme.neutralGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Preferred Food Types',
                                  style: TextStyle(
                                    color: AppTheme.textPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _availableFoodTypes.map((type) {
                                    return FilterChip(
                                      label: Text(type),
                                      selected:
                                          _preferredFoodTypes.contains(type),
                                      onSelected: (selected) {
                                        _toggleFoodType(type);
                                      },
                                      backgroundColor: Colors.white,
                                      selectedColor: AppTheme.accentColor,
                                      labelStyle: TextStyle(
                                        color:
                                            _preferredFoodTypes.contains(type)
                                                ? Colors.white
                                                : AppTheme.textPrimaryColor,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.03,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppTheme.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.isMobile(context)
                                      ? 12
                                      : 16,
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getFontSize(
                                            context, 16),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getHeight(context) * 0.02,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.backgroundColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.backgroundColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 24,
          vertical: ResponsiveHelper.isMobile(context) ? 12 : 16,
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }
}

class _AddressController {
  LatLng coordinates = const LatLng(0.0, 0.0);
}
