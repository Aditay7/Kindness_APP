# Kindness - Food Donation App

A Flutter application that connects restaurants with NGOs to reduce food waste and help those in need.

## Features

- Restaurant Dashboard

  - Post surplus food donations
  - Track active donations
  - View impact reports
  - Manage profile and settings

- NGO Dashboard
  - Browse available donations
  - Claim donations
  - Schedule pickups
  - Track volunteer activities
  - Submit impact reports

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/kindness.git
cd kindness
```

2. Install dependencies:

```bash
flutter pub get
```

3. Create a `.env` file in the root directory and add your API keys:

```
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

4. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── screens/
│   ├── auth/
│   │   ├── restaurant_signup_screen.dart
│   │   └── ngo_signup_screen.dart
│   ├── restaurant/
│   │   ├── restaurant_dashboard_screen.dart
│   │   └── post_donation_screen.dart
│   └── ngo/
│       └── ngo_dashboard_screen.dart
├── theme/
│   └── app_theme.dart
└── main.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Google Maps Platform for location services
- All contributors who help make this project better
