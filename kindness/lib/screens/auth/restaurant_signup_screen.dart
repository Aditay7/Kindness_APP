import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:Kindness/screens/restaurant/restaurant_dashboard_screen.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import '../../services/api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantSignupScreen extends StatefulWidget {
  const RestaurantSignupScreen({super.key});

  @override
  State<RestaurantSignupScreen> createState() => _RestaurantSignupScreenState();
}

class _RestaurantSignupScreenState extends State<RestaurantSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxIdController = TextEditingController();
  final List<String> _foodSafetyCertificates = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _apiService = ApiService();

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: 'restaurant',
        phone: _phoneController.text.trim(),
        address: {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'country': _countryController.text.trim(),
        },
        taxId: _taxIdController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/restaurant-dashboard');
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
                            'Restaurant Sign Up',
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
                            label: 'Restaurant Name',
                            icon: Icons.restaurant,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter restaurant name';
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
                            controller: _taxIdController,
                            label: 'Tax ID',
                            icon: Icons.numbers,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter tax ID';
                              }
                              return null;
                            },
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
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Already have an account? Login'),
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
    _taxIdController.dispose();
    super.dispose();
  }
}

class _AddressController {
  LatLng coordinates = const LatLng(0.0, 0.0);
}
