# Smart Study Assistant - Flutter Mobile App

A beautiful, modern Flutter mobile application for the Smart Study Assistant system with smooth animations and an attractive UI.

## Features

- 🔐 **Authentication** - Beautiful login and signup screens with animations
- 📝 **Notes Management** - Create text notes and upload files with a modern interface
- ✅ **Task Management** - Full CRUD operations for tasks with status tracking
- 🤖 **AI Assistant** - Chat, summarize text, and generate quizzes with tabbed interface
- 📊 **Analytics Dashboard** - Beautiful visualizations of your study progress
- 🎨 **Modern UI** - Gradient backgrounds, smooth animations, and Material Design 3
- 📱 **Responsive** - Optimized for smartphones with intuitive navigation

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / Xcode (for mobile development)
- Backend server running (see main project README)

## Installation

1. Navigate to the Frontend-Mobile directory:
```bash
cd Frontend-Mobile
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. (Optional) Update the backend URL in `lib/main.dart` if your backend is not deployed:
```dart
setBaseUrl('http://your-backend-url/api');
```

## Running the Application

### Android
```bash
flutter run
```

### iOS
```bash
flutter run
```

### Web (for testing)
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart        # Theme configuration
├── widgets/
│   ├── animated_card.dart    # Reusable animated card widget
│   ├── stats_card.dart       # Statistics card widget
│   └── loading_shimmer.dart  # Loading shimmer effect
├── screens/
│   ├── login_screen.dart     # Login screen
│   ├── signup_screen.dart    # Signup screen
│   ├── dashboard_screen.dart # Main dashboard
│   ├── notes_screen.dart     # Notes management
│   ├── tasks_screen.dart     # Task management
│   ├── ai_screen.dart        # AI Assistant
│   └── analytics_screen.dart # Analytics dashboard
├── services/
│   └── api_service.dart      # API service layer
└── providers/
    └── auth_provider.dart    # Authentication provider
```

## Dependencies

- `flutter` - Flutter SDK
- `http` - HTTP client for API calls
- `provider` - State management
- `shared_preferences` - Local storage
- `file_picker` - File upload functionality
- `intl` - Date formatting
- `flutter_animate` - Smooth animations
- `google_fonts` - Beautiful typography
- `shimmer` - Loading effects

## Features Overview

### Dashboard
- Welcome message with user name
- Statistics cards showing notes, tasks, completion rate, and productivity score
- Quick action cards for easy navigation
- Pull-to-refresh functionality

### Notes
- Create text notes with title and content
- Upload files (PDF, images, etc.)
- View all notes in a beautiful card layout
- View note details in a dialog

### Tasks
- Create tasks with name, description, due date, and status
- Update task status (Pending, In Progress, Completed)
- Visual indicators for overdue tasks
- Task statistics overview

### AI Assistant
- **Chat Tab**: Interactive chat with AI assistant
- **Summarize Tab**: Summarize long text content
- **Quiz Tab**: Generate quizzes from study material with answer checking

### Analytics
- Productivity score visualization
- Study time tracking
- Task completion statistics
- Notes and tasks overview
- Productivity insights

## Design Features

- **Gradient Backgrounds**: Beautiful gradient backgrounds throughout the app
- **Smooth Animations**: Fade-in, slide, and scale animations on screen transitions
- **Material Design 3**: Modern Material Design components
- **Custom Theme**: Consistent color scheme and typography
- **Responsive Layout**: Optimized for different screen sizes
- **Loading States**: Elegant loading indicators and shimmer effects

## API Integration

The app communicates with the backend API through the `ApiService` class. All API calls are automatically authenticated using JWT tokens stored in shared preferences.

## Notes

- The backend must be running and accessible
- JWT tokens are stored securely in shared preferences
- File uploads are handled through multipart requests
- The AI features require the backend to have a valid Gemini API key configured

## Troubleshooting

If you encounter issues:

1. Make sure all dependencies are installed: `flutter pub get`
2. Check that your backend is running and accessible
3. Verify the backend URL in `lib/main.dart`
4. Check Flutter and Dart versions are compatible
5. Run `flutter doctor` to check your Flutter setup

## License

Part of the Smart Study Assistant System project.
