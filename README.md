# 📱 Comptron - Student Event Companion App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=for-the-badge)

*A comprehensive mobile application for university club event management*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 🌟 Overview

Comptron is a modern, feature-rich mobile application built with Flutter that serves as the ultimate companion for university students and club organizers. It provides a centralized platform for managing events, announcements, resources, and student engagement within academic communities.

### 🎯 Key Highlights
- **Cross-platform**: Runs seamlessly on both Android and iOS
- **Real-time Updates**: Live event information and notifications
- **Offline Support**: Works without internet connectivity
- **QR Code Integration**: Easy event check-ins and registration
- **Role-based Access**: Different features for students and administrators
- **Modern UI**: Beautiful Material Design 3 interface

---

## ✨ Features

### 👤 **User Management**
- 🔐 **Multi-modal Authentication**: Google OAuth & local authentication
- 👥 **Role-based Access Control**: Student and Admin roles
- 🏆 **Achievement System**: Badges and recognition for active participation
- 📱 **Offline Login**: Access app without internet connection

### 📅 **Event Management**
- 🎪 **Comprehensive Events**: Workshops, seminars, conferences, and meetups
- 📝 **Easy Registration**: One-tap event registration with capacity management
- ⏰ **Smart Scheduling**: Time-based filtering (upcoming, ongoing, past)
- 🏷️ **Tag System**: Organize events with searchable tags
- 📍 **Location Support**: Both physical and virtual events
- 📊 **Registration Analytics**: Track attendance and engagement

### 📢 **Communication**
- 📣 **Announcements**: Club updates and important notifications
- 🔗 **Event Links**: Connect announcements to specific events
- 📰 **Real-time Updates**: Stay informed with latest news

### 📚 **Resource Center**
- 🔗 **Multiple Formats**: Links, documents, videos, and images
- 🏷️ **Categorized Content**: Tag-based organization for easy discovery
- 🔍 **Smart Search**: Find resources quickly with advanced search
- 📱 **Direct Access**: Open resources directly from the app

### 🔧 **Administrative Tools**
- 👑 **Admin Dashboard**: Comprehensive management interface
- 📊 **Analytics**: Event participation and user engagement metrics
- 🎫 **QR Code Management**: Generate and scan event check-in codes
- 📝 **Content Management**: Create and manage events, announcements, and resources

### 🎨 **User Experience**
- 🌙 **Dark/Light Themes**: Automatic and manual theme switching
- ✨ **Smooth Animations**: Polished transitions and loading states
- 📱 **Responsive Design**: Optimized for all screen sizes
- 🔍 **Advanced Search**: Real-time filtering and search capabilities

---

## 🚀 Installation

### Prerequisites
- **Flutter SDK**: Version 3.9.2 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **MongoDB Atlas** account (for database)
- **Android/iOS Device** or Emulator

### 🛠️ Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Coder69-ops/comptron2.git
   cd comptron2/comptron
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration**
   ```bash
   # Copy the environment template
   cp .env.example .env
   
   # Edit .env file with your configurations
   # Add your MongoDB connection string, API keys, etc.
   ```

4. **Database Setup**
   - Create a MongoDB Atlas cluster
   - Add your connection string to `.env` file
   - Run the app to automatically create collections

5. **Run the Application**
   ```bash
   # For development
   flutter run
   
   # For release build
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

### 📝 Environment Variables

Create a `.env` file in the root directory:

```env
# MongoDB Configuration
MONGODB_URI=your_mongodb_connection_string
DATABASE_NAME=comptron

# Firebase Configuration (Optional)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id

# Other API Keys
GOOGLE_MAPS_API_KEY=your-google-maps-key
```

---

## 📱 Usage

### 👤 **For Students**

1. **Getting Started**
   - Download and install the app
   - Sign up with your university email
   - Complete your profile setup

2. **Discovering Events**
   - Browse upcoming events on the home screen
   - Use search and filters to find relevant events
   - View detailed event information

3. **Event Registration**
   - Tap on any event to view details
   - Click "Register" to secure your spot
   - Receive confirmation and QR code

4. **Event Check-in**
   - Show your QR code at the event
   - Get checked in by organizers
   - Earn badges for participation

### 👑 **For Administrators**

1. **Admin Access**
   - Log in with admin credentials
   - Access the admin dashboard

2. **Event Management**
   - Create new events with all details
   - Set capacity and registration limits
   - Monitor registration statistics

3. **Content Management**
   - Post announcements for students
   - Upload resources and materials
   - Manage user permissions

4. **Event Check-ins**
   - Use QR scanner for event check-ins
   - Track attendance in real-time
   - Generate attendance reports

---

## 🏗️ Architecture

### 🧱 **Project Structure**
```
lib/
├── 📱 main.dart                    # Application entry point
├── 🔧 core/                       # Core functionality
│   ├── 📊 models/                 # Data models
│   ├── 🔌 services/               # Business logic services
│   ├── 🎨 theme/                  # App theming
│   └── 🧩 widgets/                # Reusable components
├── ✨ features/                   # Feature modules
│   ├── 🔐 auth/                   # Authentication
│   ├── 📅 events/                 # Event management
│   ├── 📢 announcements/          # Announcements
│   ├── 📚 resources/              # Resource center
│   ├── 👤 profile/                # User profiles
│   └── 👑 admin/                  # Admin features
└── 🧪 test/                      # Unit tests
```

### 🔧 **Technology Stack**

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Framework** | Flutter 3.9.2+ | Cross-platform mobile development |
| **Language** | Dart | Programming language |
| **Database** | MongoDB Atlas | Cloud NoSQL database |
| **State Management** | Provider + BLoC | Application state management |
| **Authentication** | Google OAuth + Local | User authentication |
| **Local Storage** | Hive | Offline data storage |
| **Notifications** | Flutter Local Notifications | Push notifications |
| **QR Codes** | QR Flutter + Mobile Scanner | QR code generation/scanning |
| **HTTP Client** | Dio | API communication |
| **UI Components** | Material Design 3 | Modern UI framework |

### 🗄️ **Database Schema**

#### Users Collection
```json
{
  "_id": "ObjectId",
  "email": "student@university.edu",
  "name": "Student Name",
  "role": "student|admin",
  "registeredEvents": ["event_id_1", "event_id_2"],
  "badges": ["early_bird", "active_participant"],
  "createdAt": "2025-11-08T00:00:00.000Z"
}
```

#### Events Collection
```json
{
  "_id": "ObjectId",
  "title": "Flutter Workshop 2024",
  "description": "Learn Flutter development...",
  "startDate": "2025-11-15T14:00:00.000Z",
  "location": "Computer Lab A",
  "type": "workshop",
  "capacity": 50,
  "registeredCount": 25,
  "tags": ["flutter", "mobile", "development"],
  "isPublished": true
}
```

---

## 🧪 Testing

### 🔍 **Testing Features**

The app includes comprehensive testing capabilities:

- **Database Connectivity Tests**: Verify MongoDB connection
- **Authentication Tests**: Test login/logout functionality  
- **CRUD Operations**: Test data creation, reading, updating, deletion
- **UI Tests**: Widget and integration testing
- **Sample Data Population**: Automated test data generation

### 🏃 **Running Tests**

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/models/registration_test.dart

# Run with coverage
flutter test --coverage
```

### 📊 **Database Testing**

Use the built-in database test screen:
1. Open the app
2. Navigate to `/db-test` route
3. Run connectivity and CRUD tests
4. Populate sample data for testing

---

## 🤝 Contributing

We welcome contributions to improve Comptron! Here's how you can help:

### 🐛 **Bug Reports**
- Use the GitHub issue tracker
- Provide detailed reproduction steps
- Include screenshots if applicable

### ✨ **Feature Requests**
- Describe the feature and its benefits
- Provide mockups or examples if possible
- Discuss implementation approach

### 💻 **Code Contributions**

1. **Fork the Repository**
   ```bash
   git fork https://github.com/Coder69-ops/comptron2.git
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes**
   - Follow Dart/Flutter style guidelines
   - Add tests for new features
   - Update documentation

4. **Submit Pull Request**
   - Describe changes clearly
   - Reference related issues
   - Ensure all tests pass

### 📋 **Development Guidelines**

- **Code Style**: Follow Dart official style guide
- **Commits**: Use conventional commit messages
- **Testing**: Add tests for new functionality
- **Documentation**: Update README and code comments
- **Performance**: Optimize for mobile devices

---

## 🛣️ Roadmap

### 🚀 **Version 2.0** (Coming Soon)
- [ ] Push notifications for event updates
- [ ] Enhanced QR code functionality
- [ ] Calendar integration
- [ ] Advanced analytics dashboard
- [ ] Multi-language support

### 🔮 **Future Plans**
- [ ] Web platform (Flutter Web)
- [ ] AI-powered event recommendations
- [ ] Social features and discussions
- [ ] Integration with university systems
- [ ] Advanced reporting tools

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Coder69-ops**
- GitHub: [@Coder69-ops](https://github.com/Coder69-ops)
- Project Link: [https://github.com/Coder69-ops/comptron2](https://github.com/Coder69-ops/comptron2)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- MongoDB for reliable cloud database services
- Material Design team for beautiful UI guidelines
- Open source community for valuable packages and plugins

---

## 📞 Support

If you find this project helpful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting issues
- 🤝 Contributing to the codebase
- 📢 Sharing with others

For support, email us at [support@comptron.dev](mailto:support@comptron.dev) or create an issue on GitHub.

---

<div align="center">

**Made with ❤️ for the university community**

*Empowering student engagement through technology*

</div>
