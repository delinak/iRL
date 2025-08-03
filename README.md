# iRL - Location-Based Social Connection App

A SwiftUI iOS app that enables organic, low-pressure social connections in public spaces through subtle location-based signaling.

## 🌟 Overview

iRL is a social app designed to make spontaneous conversation in public spaces feel more natural, safe, and inviting. Users can subtly signal their openness to connection when they're in public venues like coffee shops, libraries, or parks, helping to break down social barriers and facilitate real-world interactions.

## 🎯 Problem Statement

Despite being physically surrounded by others in public spaces, many people struggle to initiate casual conversations due to social norms, fear of rejection, and anxiety. iRL provides a soft, opt-in signal for social availability, helping users express openness to conversation in a lightweight, respectful way.

## 🚀 Features

### ✅ Implemented (MVP)
- **Multi-step Onboarding Flow** - Name, photo, birthday, interests, permissions
- **Location-Based Visibility** - Only visible within 100ft of recognized public places
- **Interactive Map View** - See nearby users with clustering and zoom controls
- **Profile Management** - Edit profile picture, interests, and communication intent
- **Swipe-to-Signal** - Intuitive swipe-up gesture to go visible
- **Mock User System** - 8 realistic demo profiles for testing
- **Glassmorphism UI** - Modern, elegant design with soft shadows and rounded corners
- **Dark Mode Support** - Automatic adaptation to system appearance
- **Responsive Design** - Optimized for iPhone with proper safe areas

### 🔄 In Progress / Planned
- **Real Backend Integration** - Currently using mock data and local storage
- **Push Notifications** - Status change alerts and location-based notifications
- **Chat Functionality** - Direct messaging between users
- **Advanced Filtering** - Filter by interests, age, distance
- **Block/Report Features** - User safety and moderation tools
- **Analytics & Metrics** - User engagement tracking
- **Social Features** - Friend connections, activity feed

## 🛠 Tech Stack

### Frontend
- **SwiftUI** - Modern declarative UI framework
- **Swift** - Primary programming language
- **Combine** - Reactive programming for data flow
- **MapKit** - Location services and map integration
- **CoreLocation** - GPS and location permissions

### Architecture
- **MVVM Pattern** - Model-View-ViewModel architecture
- **ObservableObject** - SwiftUI state management
- **UserDefaults** - Local data persistence
- **@EnvironmentObject** - Dependency injection

### Design System
- **Glassmorphism** - Frosted glass effects with soft shadows
- **SF Symbols** - Apple's icon system
- **Custom Color Palette** - Soft oranges, pastel greens, mellow yellows
- **Responsive Typography** - Dynamic font sizing and weights

### Current Backend Status
- **Local Storage Only** - UserDefaults for persistence
- **Mock Data** - Simulated user profiles and locations
- **No Server** - All data stored locally on device

## 📱 Screenshots

*[Screenshots will be added here]*

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 18.0+
- iPhone/iPad device or simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/iRL.git
   cd iRL
   ```

2. **Open in Xcode**
   ```bash
   open iRL.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run
   - Or use Product → Run in Xcode menu

### First Run
1. Complete the onboarding flow
2. Grant location permissions when prompted
3. Go to the Map tab to see mock users
4. Swipe up from the Home tab to go visible

## 🏗 Project Structure

```
iRL/
├── Models/
│   ├── User.swift              # User data model
│   └── AppConstants.swift      # App-wide constants
├── ViewModels/
│   ├── AppStateManager.swift   # Global app state
│   └── OnboardingViewModel.swift # Onboarding logic
├── Views/
│   ├── Components/
│   │   └── GlassmorphicCard.swift # Reusable UI components
│   ├── Onboarding/
│   │   └── OnboardingView.swift   # Multi-step onboarding
│   └── Screens/
│       ├── HomeView.swift      # Main feed screen
│       ├── MapView.swift       # Interactive map
│       └── ProfileView.swift   # User profile
├── Services/
│   └── LocationService.swift   # GPS and location logic
└── ContentView.swift           # Root app view
```

## 🎨 Design Philosophy

### Glassmorphism
The app uses a modern glassmorphism design with:
- Semi-transparent backgrounds
- Soft shadows and blur effects
- Rounded corners throughout
- Subtle borders and overlays

### Color Palette
- **Primary Orange** - `#FF6B35` for main actions and highlights
- **Soft Green** - `#4CAF50` for success states and location indicators
- **Mellow Yellow** - `#FFD93D` for accents and warnings
- **System Colors** - Adaptive to light/dark mode

### Typography
- **Futura** - Custom font for app branding
- **SF Pro** - System font for body text
- **Dynamic sizing** - Responsive to accessibility settings

## 🔧 Configuration

### Location Settings
- **Visibility Radius**: 100 feet (configurable in `AppConstants.swift`)
- **Update Frequency**: Real-time with battery optimization
- **Permission Required**: Location When In Use

### Mock Data
- **8 Demo Users** - Realistic profiles with varied interests
- **Random Locations** - Within 100ft of venue center
- **Dynamic Visibility** - Some users visible, some not

## 🚧 Backend Requirements

### What Needs Implementation

#### 1. **Real Backend Service**
- **Technology**: Firebase, Supabase, or custom server
- **Database**: User profiles, location data, chat messages
- **Authentication**: User registration and login
- **Real-time Updates**: Live location and status changes

#### 2. **Push Notifications**
- **Status Changes**: When users go visible/invisible
- **Location Alerts**: When leaving visibility radius
- **New Matches**: When compatible users are nearby
- **Chat Messages**: Real-time messaging notifications

#### 3. **Location Services**
- **Venue Recognition**: API to identify public places
- **Geofencing**: Automatic visibility based on location
- **Distance Calculation**: Real-time proximity detection
- **Location History**: Track frequent locations

#### 4. **User Management**
- **Profile Storage**: Cloud-based user profiles
- **Image Upload**: Profile picture storage and CDN
- **Privacy Controls**: Block, report, and safety features
- **Analytics**: User engagement and app usage metrics

#### 5. **Social Features**
- **Chat System**: Real-time messaging between users
- **Friend Connections**: Add and manage connections
- **Activity Feed**: Recent interactions and updates
- **Matching Algorithm**: Compatibility scoring

## 🔒 Privacy & Security

### Current Implementation
- **Local Storage Only** - No data transmitted to servers
- **Location Privacy** - Only shared when explicitly visible
- **Minimal Permissions** - Only location and camera access
- **No Tracking** - No analytics or user behavior tracking

### Planned Security Features
- **End-to-End Encryption** - For all communications
- **Data Anonymization** - Privacy-preserving location sharing
- **Consent Management** - Granular privacy controls
- **GDPR Compliance** - Data protection and user rights

## 🧪 Testing

### Current Test Coverage
- **UI Components** - All views render correctly
- **Navigation Flow** - Onboarding and tab navigation
- **Location Services** - GPS permissions and updates
- **Mock Data** - Realistic user interactions

### Testing Needed
- **Unit Tests** - ViewModels and business logic
- **Integration Tests** - API and backend services
- **UI Tests** - User interaction flows
- **Performance Tests** - Battery and memory usage

## 📈 Performance

### Current Optimizations
- **Lazy Loading** - Images and content loaded on demand
- **Battery Efficiency** - Optimized location updates
- **Memory Management** - Proper cleanup of resources
- **Smooth Animations** - 60fps interactions

### Performance Targets
- **Battery Usage** - <5% per hour of active use
- **Memory Usage** - <100MB in normal operation
- **Launch Time** - <2 seconds cold start
- **Location Accuracy** - Within 10 feet

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style
- Follow Swift style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Apple** - For SwiftUI and iOS development tools
- **Design Community** - For glassmorphism design inspiration
- **Open Source** - For various libraries and resources

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/iRL/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/iRL/discussions)
- **Email**: your.email@example.com

---

**Made with ❤️ using SwiftUI and modern iOS development practices** 