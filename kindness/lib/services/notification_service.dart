import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../screens/ngo/ngo_donation_details_screen.dart';
import 'api_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    print('Initializing notification service...');

    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Notification permission status: ${settings.authorizationStatus}');

    // Get FCM token
    String? token;
    try {
      if (kIsWeb) {
        // For web, only get the token without VAPID key for now
        token = await _fcm.getToken();
      } else {
        // For mobile platforms
        token = await _fcm.getToken();
      }
      print('FCM Token: $token'); // For debugging

      // Save token to backend
      if (token != null) {
        await _saveTokenToBackend(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }

    if (!kIsWeb) {
      // Initialize local notifications (only for mobile)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Local notification tapped with payload: ${response.payload}');
          final payload = response.payload;
          if (payload != null) {
            final donationId = payload;
            _handleNotificationTap(donationId);
          }
        },
      );
      print('Local notifications initialized');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle background/terminated messages when tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Background notification tapped with data: ${message.data}');
      final donationId = message.data['donationId'];
      if (donationId != null) {
        _handleNotificationTap(donationId);
      }
    });

    // Check for initial message (app opened from terminated state)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print(
          'App opened from terminated state with message: ${initialMessage.data}');
      final donationId = initialMessage.data['donationId'];
      if (donationId != null) {
        _handleNotificationTap(donationId);
      }
    }

    print('Message handlers set up');
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    print('Handling message: ${message.messageId}');
    print('Message data: ${message.data}');

    final data = message.data;
    final restaurantName = data['restaurantName'] ?? 'Unknown Restaurant';
    final foodType = data['foodType'] ?? 'Unknown Food';
    final donationId = data['donationId'] ?? '';

    if (kIsWeb) {
      // For web, show browser notification
      if (await _fcm.requestPermission().then((settings) =>
          settings.authorizationStatus == AuthorizationStatus.authorized)) {
        final notification = message.notification;
        if (notification != null) {
          print('Showing web notification');
          // Web notifications are handled by the browser
        }
      }
    } else {
      // For mobile, show local notification
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'donation_channel',
        'Donation Notifications',
        channelDescription: 'Notifications for new food donations',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF4CAF50),
        enableLights: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(''),
        category: AndroidNotificationCategory.message,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        '${restaurantName} Posted a new donation of ${foodType}',
        'Tap to view details',
        platformDetails,
        payload: donationId,
      );
    }
    print('Notification shown successfully');
  }

  Future<void> _handleNotificationTap(String donationId) async {
    print('Handling notification tap for donation: $donationId');
    try {
      print('Fetching donation details...');
      final donation = await _apiService.getDonationDetails(donationId);
      print('Fetched donation details successfully: ${donation.foodType}');

      if (navigatorKey.currentState == null) {
        print('Error: Navigator key current state is null');
        return;
      }

      print('Attempting to navigate to donation details screen...');
      await navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => NGODonationDetailsScreen(
            donationId: donationId,
            foodImage: donation.images.isNotEmpty ? donation.images[0] : '',
            foodType: donation.foodType,
            quantity: int.parse(donation.quantity),
            allergens: donation.allergens,
            restaurantName: donation.restaurantId.name,
            restaurantAddress:
                '${donation.restaurantId.address.street}, ${donation.restaurantId.address.city}',
            restaurantRating: 5.0,
            pickupDeadline: donation.pickupDeadline,
            restaurantPhone: donation.restaurantId.phone,
            status: donation.status,
          ),
        ),
      );
      print('Successfully navigated to donation details screen');
    } catch (e, stackTrace) {
      print('Error navigating to donation details: $e');
      print('Stack trace: $stackTrace');

      // Show error message to user
      if (navigatorKey.currentState != null) {
        String errorMessage =
            'The donation may have been removed or you may not have permission to view it.';

        // Check if it's a permission error
        if (e.toString().contains('Access denied') ||
            e.toString().contains('Insufficient permissions')) {
          errorMessage =
              'You do not have permission to view this donation. Please make sure you are logged in as an NGO.';
        }

        // Check if it's a 404 error (donation not found)
        if (e.toString().contains('Cannot GET') ||
            e.toString().contains('404')) {
          errorMessage = 'This donation no longer exists or has been removed.';
        }

        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load donation details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    try {
      print('Saving FCM token to backend: $token');
      await _apiService.updateFCMToken(token);
      print('FCM token saved successfully');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}
