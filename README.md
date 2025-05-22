# Video Analytics System (VAS)

A Flutter application that attempts to replicates the core functionality of YouTube Studio, allowing content creators to manage their YouTube channel, videos, and analytics.

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
git clone https://github.com/k232003-TalalAli/Video-Platform-Analytics-System.git
```

2. Navigate to the project directory:
```bash
cd Video-Platform-Analytics-System
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Login Credentials
Usernames: "umer", "Danny", "Talal", "Nemo", "Lelouch"
Password: Umer@12g

## Project Structure

```
VAS/
├── Documentation/
│   ├── Video_Platform_Analytics_System_SDS.pdf
│   └── Video_Platform_Analytics_System_SRS.pdf
├── imgs/
│   ├── thumbnail_1.jpg
│   ├── thumbnail_2.jpg
│   ├── thumbnail_3.jpg
│   └── thumbnail_4.jpg
├── lib/
│   ├── DB/
│   │   ├── API/
│   │   │   ├── db_api.dart
│   │   │   └── Widget_database_utility.dart
│   │   ├── controllers/
│   │   │   └── database_helper.dart
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   ├── video_metric.dart
│   │   │   ├── video.dart
│   │   │   └── video_metric.dart
│   │   ├── repositories/
│   │   │   ├── user_repository.dart
│   │   │   ├── video_metric_repository.dart
│   │   │   └── video_repository.dart
│   │   ├── tests/
│   │   └── youtube_analytics.db
│   ├── login/
│   │   ├── login_database_helper.dart
│   │   ├── login_users.db
│   │   └── user_session.dart
│   ├── screens/
│   │   ├── content_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── feedback_screen.dart
│   │   └── login_screen.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── widgets/
│   │   ├── content/
│   │   │   └── video_list_widget.dart
│   │   ├── dashboard/
│   │   │   ├── analytics_card.dart
│   │   │   ├── line_graph.dart
│   │   │   └── overview_widget.dart
│   │   ├── feedback/
│   │   │   └── feedback_widget.dart
│   │   ├── custom_app_bar.dart
│   │   ├── custom_drawer.dart
│   │   ├── profile_picture.dart
│   │   └── profile_settings_dialog.dart
│   └── main.dart
├── .gitignore
├── analysis_operations.yaml
├── generate_dummy_data.py
├── graphs.py
├── pubspec.yaml
└── README.md
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
