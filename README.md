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

# Video Platform Analytics System

## Color Theme

The application uses a modern, professional color theme:

### Primary Colors
- **Primary**: `#3B82F6` (Bright blue) - Main actions, buttons, and highlighted elements
- **Secondary**: `#10B981` (Emerald green) - Success states and growth indicators
- **Accent**: `#F59E0B` (Amber) - Warnings and attention-grabbing elements

### Background & Surface Colors
- **Background**: `#F9FAFB` (Off-white) - Main app background
- **Surface**: `#FFFFFF` (White) - Cards, dialogs, modals
- **Dark Surface**: `#1F2937` (Dark slate) - For dark mode or contrasting elements

### Text Colors
- **Primary Text**: `#111827` (Near black) - Main text
- **Secondary Text**: `#6B7280` (Medium gray) - Less important text
- **Disabled**: `#D1D5DB` (Light gray) - Inactive elements

### Graph Colors
- **Data Series 1**: `#3B82F6` (Blue)
- **Data Series 2**: `#10B981` (Green)
- **Data Series 3**: `#F59E0B` (Amber)
- **Data Series 4**: `#EF4444` (Red)
- **Data Series 5**: `#8B5CF6` (Purple)

## Development

The theme is implemented using Flutter's theming system. The theme configuration is stored in `lib/theme/app_theme.dart`.

To modify the theme:
1. Edit the color values in `lib/theme/app_theme.dart`
2. Rebuild the application to see changes

For custom widgets that need theme colors, import the theme file:
```dart
import '../theme/app_theme.dart';
```

And use the color constants:
```dart
Color myColor = AppTheme.primaryColor;
```
