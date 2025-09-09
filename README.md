# Ar-Rahnu Mobile App (Muamalat Pajak Gadai Islam)

A comprehensive Flutter mobile application for Islamic pawnbroking services (Ar-Rahnu) developed for Bank Muamalat Malaysia Berhad (BMMB). This app provides a digital platform for customers to access Islamic pawnbroking services, manage their accounts, and interact with various financial services.

## 📱 Features

### Core Functionality
- **User Authentication & Security**
  - Secure login system with JWT token management
  - Biometric authentication support
  - Secure storage for sensitive data

- **Dashboard & Navigation**
  - Modern, intuitive user interface
  - Real-time account information
  - Quick access to main services

- **Ar-Rahnu Services**
  - Collateral management
  - Loan calculator
  - Bidding system for auctions
  - Price monitoring and updates

- **Additional Features**
  - Branch locator
  - Campaign and promotions
  - Gallery and information center
  - Profile management

## 🛠️ Technical Specifications

### Development Environment
- **Flutter Version**: 3.35.3
- **Dart SDK**: >=3.2.6 <4.0.0
- **Gradle Version**: 8.7
- **Android Gradle Plugin**: 8.6.0
- **Kotlin Version**: 2.1.0
- **iOS Deployment Target**: 13.0

### Key Dependencies
- **State Management**: GetX (^4.6.6)
- **UI Components**: Material Design with custom theming
- **HTTP Client**: http (^1.2.1)
- **Security**: flutter_secure_storage (^9.0.0)
- **Authentication**: JWT decoder (^2.0.1)
- **UI Enhancements**: 
  - carousel_slider (^5.0.0)
  - smooth_page_indicator (^1.1.0)
  - webview_flutter (^4.5.0)
  - flutter_spinkit (^5.2.0)

### Design System
- **Typography**: Montserrat font family
- **Theming**: FlexColorScheme for dynamic theming
- **Icons**: Custom and Material Icons
- **Responsive Design**: Adaptive layouts for various screen sizes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.35.3 or higher)
- Dart SDK (3.2.6 or higher)
- Android Studio / VS Code
- Xcode (for iOS development)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mralif93/arrahnu_mobile_app.git
   cd arrahnu_mobile_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate app icons** (optional)
   ```bash
   flutter packages pub run flutter_launcher_icons:main
   ```

4. **Run the application**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

### Building for Production

#### Android APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

#### iOS App
```bash
# iOS build
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── components/          # Reusable UI components
│   ├── QAvatar.dart
│   ├── QButton.dart
│   ├── QCard.dart
│   └── ...
├── constant/            # App constants and configurations
│   ├── color.dart
│   ├── style.dart
│   └── variables.dart
├── controllers/         # Business logic controllers
│   └── authorization.dart
├── model/              # Data models
│   ├── account.dart
│   ├── bidding.dart
│   ├── collateral.dart
│   └── user.dart
├── pages/              # App screens/pages
│   ├── dashboard.dart
│   ├── login.dart
│   ├── calculator.dart
│   └── ...
├── storage/            # Local storage management
│   └── secure_storage.dart
├── theme/              # App theming
│   ├── theme_constant.dart
│   └── theme_provider.dart
├── utils/              # Utility functions
├── widget/             # Custom widgets
└── main.dart           # App entry point
```

## 🔧 Configuration

### Environment Setup
1. **Android Configuration**
   - Minimum SDK: 21
   - Target SDK: Latest
   - Gradle: 8.7

2. **iOS Configuration**
   - Deployment Target: 13.0
   - Xcode: 16.4+

3. **Security Configuration**
   - Secure storage for sensitive data
   - JWT token management
   - Encrypted local storage

## 🎨 UI/UX Features

- **Modern Design**: Clean, professional interface following Material Design principles
- **Custom Components**: Reusable UI components for consistency
- **Responsive Layout**: Adaptive design for various screen sizes
- **Loading States**: Smooth loading animations and progress indicators
- **Error Handling**: User-friendly error messages and validation

## 🔐 Security Features

- **Secure Storage**: Sensitive data encrypted using flutter_secure_storage
- **JWT Authentication**: Secure token-based authentication
- **Data Validation**: Input validation and sanitization
- **Secure Communication**: HTTPS for all API communications

## 📱 Supported Platforms

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 13.0+
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)

## 🚀 Performance Optimizations

- **Gradle 8.7**: Latest Gradle version for improved build performance
- **Tree Shaking**: Optimized bundle size with tree-shaking enabled
- **Image Optimization**: Compressed assets and optimized loading
- **Lazy Loading**: Efficient memory management

## 📋 Development Guidelines

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation

### Git Workflow
- Use descriptive commit messages
- Create feature branches for new features
- Test thoroughly before merging
- Keep the repository clean and organized

## 🐛 Troubleshooting

### Common Issues

1. **Gradle Build Issues**
   ```bash
   flutter clean
   cd android && ./gradlew clean
   flutter pub get
   ```

2. **iOS Build Issues**
   ```bash
   cd ios && pod install
   flutter clean && flutter pub get
   ```

3. **Dependency Issues**
   ```bash
   flutter pub deps
   flutter pub upgrade
   ```

## 📄 License

This project is proprietary software developed for Bank Muamalat Malaysia Berhad (BMMB). All rights reserved.

## 👥 Development Team

- **Project**: Ar-Rahnu Mobile App
- **Client**: Bank Muamalat Malaysia Berhad (BMMB)
- **Version**: 2.0.1+10013

## 📞 Support

For technical support or questions regarding this application, please contact the development team or refer to the project documentation.

---

**Note**: This application is designed specifically for Islamic pawnbroking services and follows Shariah-compliant financial principles.