import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ngo.dart';
import '../models/donation.dart' as donation_model;
import 'dart:io';
import 'dart:math' as math;

class ApiService {
  // static const String baseUrl = 'http://192.168.6.161:5000';
  static const String baseUrl =
      'https://deciding-extremely-chamois.ngrok-free.app';
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Decode JWT token to get user type
  String _decodeUserType(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';

      final normalizedPayload = base64Url.normalize(parts[1]);
      final decodedPayload = base64Url.decode(normalizedPayload);
      final payloadString = utf8.decode(decodedPayload);
      final payload = jsonDecode(payloadString);
      return payload['userType'] ?? '';
    } catch (e) {
      print('Error decoding token: $e');
      return '';
    }
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    int retryCount = 0,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('Making $method request to $uri');
      print('Request body: ${body != null ? jsonEncode(body) : 'null'}');

      final request = http.Request(method, uri);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';

      if (requiresAuth) {
        final token = await getToken();
        if (token == null) {
          throw Exception('No authentication token found');
        }
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (body != null) {
        request.body = jsonEncode(body);
      }

      print('Request headers: ${request.headers}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 400) {
        print('Error response: ${response.body}');
      }

      return response;
    } catch (e, stackTrace) {
      print('Request error: $e');
      print('Stack trace: $stackTrace');
      if (retryCount < maxRetries) {
        print('Retrying request (${retryCount + 1}/$maxRetries)...');
        await Future.delayed(retryDelay);
        return _makeRequest(method, endpoint,
            body: body, retryCount: retryCount + 1, requiresAuth: requiresAuth);
      }
      rethrow;
    }
  }

  // Register a new user (restaurant or NGO)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String userType,
    required String phone,
    required Map<String, dynamic> address,
    String? registrationNumber,
    List<String>? preferredFoodTypes,
    Map<String, dynamic>? serviceArea,
    String? taxId,
    String? ngoType,
  }) async {
    try {
      print('Starting registration process for $userType');
      final response = await _makeRequest(
        'POST',
        '/api/auth/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'userType': userType,
          'phone': phone,
          'address': address,
          'registrationNumber': registrationNumber,
          'preferredFoodTypes': preferredFoodTypes,
          'serviceArea': serviceArea,
          'taxId': taxId,
          'ngoType': ngoType,
        },
        requiresAuth: false, // Registration doesn't require auth
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Registration failed');
        }

        // Extract token and user type from response
        final token = data['data']['token'];
        if (token == null) {
          throw Exception('No token received from server');
        }

        // Store auth data after successful registration
        await _storeAuthData(token, userType);
        print('Registration successful and auth data stored');
        return data['data'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/api/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Login failed');
        }

        final token = data['data']['token'];
        if (token == null) {
          throw Exception('No token received from server');
        }

        final userType = _decodeUserType(token);
        if (userType.isEmpty) {
          throw Exception('Invalid user type in token');
        }

        await _storeAuthData(token, userType);
        return data['data'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Login failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_type');
      await prefs.remove('isLoggedIn'); // Remove login status
      print('Logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }

  // Get user type
  Future<String?> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('user_type');
      print('Retrieved user type: $userType');
      return userType;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Get auth token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print(
          'Retrieved token: ${token != null ? 'Token exists' : 'No token found'}');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> _storeAuthData(String token, String userType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_type', userType);
      print('Stored token and user type: $userType');
    } catch (e) {
      print('Error storing auth data: $e');
      throw Exception('Failed to store authentication data');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRestaurantProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _makeRequest(
        'GET',
        '/api/restaurant/profile',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(
              data['message'] ?? 'Failed to fetch restaurant profile');
        }
        return data['data'];
      } else {
        throw Exception('Failed to fetch restaurant profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching restaurant profile: $e');
      throw Exception('Failed to fetch restaurant profile: $e');
    }
  }

  // Get NGO profile
  Future<NGO> getNGOProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please log in again.');
      }

      print('Fetching NGO profile with token');
      final response = await _makeRequest(
        'GET',
        '/api/ngo/profile',
        requiresAuth: true,
      );

      print('NGO profile response status: ${response.statusCode}');
      print('NGO profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to fetch NGO profile');
        }
        return NGO.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to fetch NGO profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching NGO profile: $e');
      throw Exception('Failed to fetch NGO profile: $e');
    }
  }

  // Upload image to Cloudinary
  Future<String> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/api/restaurant/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add auth token
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      if (response.statusCode != 200) {
        throw Exception(jsonData['message'] ?? 'Failed to upload image');
      }

      return jsonData['data']['url'];
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Create a new donation
  Future<donation_model.Donation> createDonation({
    required String foodType,
    required int quantity,
    required List<String> allergens,
    required DateTime pickupDeadline,
    required String additionalNote,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      // Create donation with image URL
      final response = await _makeRequest(
        'POST',
        '/api/restaurant/donations',
        body: {
          'foodType': foodType,
          'quantity': quantity.toString(),
          'allergens': allergens,
          'pickupDeadline': pickupDeadline.toIso8601String(),
          'notes': additionalNote,
          'images': imageUrl != null ? [imageUrl] : [],
        },
      );

      print('Create donation response: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to create donation');
        }

        // Ensure we're getting the correct donation data structure
        final donationData = data['data'];
        if (donationData == null) {
          throw Exception('No donation data received from server');
        }

        // If donationData is a string (ID), fetch the full donation details
        if (donationData is String) {
          final detailsResponse = await _makeRequest(
            'GET',
            '/api/donations/$donationData',
          );

          if (detailsResponse.statusCode == 200) {
            final detailsData = jsonDecode(detailsResponse.body);
            if (!detailsData['success']) {
              throw Exception(
                  detailsData['message'] ?? 'Failed to fetch donation details');
            }
            return donation_model.Donation.fromJson(detailsData['data']);
          } else {
            throw Exception('Failed to fetch donation details');
          }
        }

        // If donationData is already a Map, use it directly
        if (donationData is Map<String, dynamic>) {
          return donation_model.Donation.fromJson(donationData);
        }

        throw Exception('Invalid donation data format received from server');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create donation');
      }
    } catch (e) {
      print('Error creating donation: $e');
      throw Exception('Failed to create donation: $e');
    }
  }

  // Get NGO details by ID
  Future<NGO> getNGODetails(String ngoId) async {
    try {
      print('Fetching NGO details for ID: $ngoId');
      final response = await _makeRequest(
        'GET',
        '/api/ngo/details/$ngoId', // Updated endpoint
      );

      print('NGO details response status: ${response.statusCode}');
      print('NGO details response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to fetch NGO details');
        }
        final ngo = NGO.fromJson(data['data']);
        print('Successfully fetched NGO details: ${ngo.name}');
        return ngo;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch NGO details');
      }
    } catch (e) {
      print('Error fetching NGO details: $e');
      rethrow;
    }
  }

  // Get restaurant's donations
  Future<List<donation_model.Donation>> getRestaurantDonations(
      {String? status}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Fetching restaurant donations with status: $status');
      final response = await _makeRequest(
        'GET',
        '/api/restaurant/donations${status != null ? '?status=$status' : ''}',
      );

      print('Donations response status: ${response.statusCode}');
      print('Donations response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to fetch donations');
        }
        final List<dynamic> donations = data['data'];
        final List<donation_model.Donation> parsedDonations = [];

        for (var donation in donations) {
          // NGO details are now populated in the response
          if (donation['claimedBy'] != null) {
            donation['claimedBy'] = {
              '_id': donation['claimedBy']['_id'],
              'name': donation['claimedBy']['name'],
              'contact': donation['claimedBy']['phone'],
            };
          }
          parsedDonations.add(donation_model.Donation.fromJson(donation));
        }
        return parsedDonations;
      } else if (response.statusCode == 401) {
        await logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch donations');
      }
    } catch (e) {
      print('Error in getRestaurantDonations: $e');
      throw Exception('Failed to fetch donations: $e');
    }
  }

  // Get available donations for NGOs
  Future<List<donation_model.Donation>> getAvailableDonations() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Fetching available donations...'); // Debug print
      final response = await _makeRequest(
        'GET',
        '/api/ngo/available-donations', // Updated endpoint
        requiresAuth: true,
      );

      print('Donations response status: ${response.statusCode}');
      print('Donations response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to fetch donations');
        }
        final List<dynamic> donations = data['data'];
        print('Parsed ${donations.length} donations'); // Debug print
        return donations
            .map((json) => donation_model.Donation.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch donations');
      }
    } catch (e) {
      print('Error in getAvailableDonations: $e');
      if (e is Exception) {
        print('Exception details: ${e.toString()}');
      }
      throw Exception('Failed to fetch donations: $e');
    }
  }

  // Claim a donation
  Future<void> claimDonation(String donationId) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Claiming donation: $donationId');
      final response = await _makeRequest(
        'POST',
        '/api/ngo/claim-donation',
        body: {
          'donationId': donationId,
          'pickupTime': DateTime.now().toIso8601String(),
        },
      );

      print('Claim response status: ${response.statusCode}');
      print('Claim response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to claim donation');
      }
    } catch (e) {
      print('Error claiming donation: $e');
      rethrow;
    }
  }

  // Get active claims for NGO
  Future<List<Map<String, dynamic>>> getActiveClaims() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Fetching active claims...');
      final response = await _makeRequest(
        'GET',
        '/api/ngo/dashboard',
      );

      print('Active claims response status: ${response.statusCode}');
      print('Active claims response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to fetch active claims');
        }
        return List<Map<String, dynamic>>.from(data['data']['activeClaims']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to fetch active claims');
      }
    } catch (e) {
      print('Error fetching active claims: $e');
      throw Exception('Failed to fetch active claims: $e');
    }
  }

  // Get donations with status
  Future<List<donation_model.Donation>> getDonations({String? status}) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Fetching donations with status: $status');
      final response = await _makeRequest(
        'GET',
        '/api/ngo/claimed-donations',
      );

      print('Donations response status: ${response.statusCode}');
      print('Donations response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to fetch donations');
        }
        final List<dynamic> donations = data['data'];
        return donations
            .map((json) => donation_model.Donation.fromJson(json))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch donations');
      }
    } catch (e) {
      print('Error fetching donations: $e');
      throw Exception('Failed to fetch donations: $e');
    }
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String status) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('Updating donation status: $donationId to $status');
      final response = await _makeRequest(
        'PUT',
        '/api/ngo/donations/$donationId',
        body: {
          'status': status,
        },
      );

      print('Update status response: ${response.statusCode}');
      print('Update status body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update donation status');
      }
    } catch (e) {
      print('Error updating donation status: $e');
      throw Exception('Failed to update donation status: $e');
    }
  }

  // Update FCM token
  Future<void> updateFCMToken(String token) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/api/notifications/update-token',
        body: {
          'fcmToken': token,
        },
        requiresAuth: true,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update FCM token');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
      throw Exception('Failed to update FCM token: $e');
    }
  }

  // Get donation details by ID
  Future<donation_model.Donation> getDonationDetails(String donationId) async {
    try {
      print('Fetching donation details for ID: $donationId');

      // Get user type from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('userType');

      // Use different endpoints based on user type
      final endpoint = userType == 'ngo'
          ? '/api/ngo/donation-details/$donationId'
          : '/api/restaurant/donation-details/$donationId';

      final response = await _makeRequest(
        'GET',
        endpoint,
      );

      print('Donation details response status: ${response.statusCode}');
      print('Donation details response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(
              data['message'] ?? 'Failed to fetch donation details');
        }
        return donation_model.Donation.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to fetch donation details');
      }
    } catch (e) {
      print('Error fetching donation details: $e');
      throw Exception('Failed to fetch donation details: $e');
    }
  }

  // Get NGO dashboard statistics
  Future<Map<String, dynamic>> getNGODashboardStats() async {
    try {
      // For now, we'll generate realistic mock data
      // In a real app, you would fetch this from your backend API
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      // Generate random but realistic statistics
      final random = math.Random();

      return {
        'mealsDistributed': 150 + random.nextInt(100), // 150-250 meals
        'beneficiaries': 120 + random.nextInt(80), // 120-200 beneficiaries
        'areasServed': 5 + random.nextInt(5), // 5-10 areas
        'co2Saved': 75 + random.nextInt(25), // 75-100 kg
        'peopleFed': 120 + random.nextInt(80), // 120-200 people
      };
    } catch (e) {
      print('Error fetching NGO dashboard stats: $e');
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Get NGO monthly impact data
  Future<List<Map<String, dynamic>>> getNGOMonthlyImpact() async {
    try {
      // For now, we'll generate realistic mock data
      // In a real app, you would fetch this from your backend API
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      // Generate random but realistic monthly data
      final random = math.Random();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      // Generate data for the last 6 months
      final List<Map<String, dynamic>> monthlyData = [];
      final currentMonth = DateTime.now().month;

      for (int i = 0; i < 6; i++) {
        final monthIndex = (currentMonth - 1 - i + 12) % 12;
        final monthName = months[monthIndex];

        // Generate a value between 50 and 150 with a slight upward trend
        final baseValue = 50 + (i * 10);
        final randomFactor = random.nextInt(20) - 10; // -10 to +10
        final value = baseValue + randomFactor;

        monthlyData.add({
          'month': monthName,
          'value': value,
        });
      }

      // Reverse to show oldest to newest
      return monthlyData.reversed.toList();
    } catch (e) {
      print('Error fetching NGO monthly impact data: $e');
      throw Exception('Failed to fetch monthly impact data: $e');
    }
  }

  // Get global food waste statistics
  Future<Map<String, dynamic>> getGlobalFoodWasteStats() async {
    try {
      // For now, we'll generate realistic mock data
      // In a real app, you would fetch this from a public API like FAO or World Bank
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      return {
        'globalWaste': {
          'amount': '1.3 billion tons',
          'description': 'of food is wasted annually',
        },
        'peopleAffected': {
          'amount': '811 million',
          'description': 'people go hungry worldwide',
        },
        'environmentalImpact': {
          'amount': '8-10%',
          'description': 'of global greenhouse gas emissions',
        },
      };
    } catch (e) {
      print('Error fetching global food waste stats: $e');
      throw Exception('Failed to fetch global food waste stats: $e');
    }
  }
}
