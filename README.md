# YouTube Studio Clone

A Flutter application that replicates the core functionality of YouTube Studio, allowing content creators to manage their YouTube channel, videos, and analytics.

## Features

- Dashboard with channel overview
- Video management
- Analytics tracking
- Comment moderation
- Channel settings

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/utube.git
```

2. Navigate to the project directory:
```bash
cd utube
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
  ├── main.dart
  ├── screens/
  │   └── dashboard_screen.dart
  ├── widgets/
  │   ├── video_card.dart
  │   └── analytics_card.dart
  └── models/
      └── video_model.dart
```

## Dependencies

- http: For API calls
- provider: For state management
- shared_preferences: For local storage
- cached_network_image: For image caching
- intl: For date formatting

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
