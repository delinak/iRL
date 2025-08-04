# iRL - Location-Based Social Connection App

A SwiftUI iOS app that enables organic, low-pressure social connections in public spaces through subtle location-based signaling.

## Overview

iRL is a social app designed to make spontaneous conversation in public spaces feel more natural, safe, and inviting. Users can subtly signal their openness to connection when they're in public venues like coffee shops, libraries, or parks, helping to break down social barriers and facilitate real-world interactions.

## Problem Statement

Despite being physically surrounded by others in public spaces, many people struggle to initiate casual conversations due to social norms, fear of rejection, and anxiety. iRL provides a soft, opt-in signal for social availability, helping users express openness to conversation in a lightweight, respectful way.

## Features

### Implemented (MVP)
- Multi-step Onboarding Flow - Name, photo, birthday, interests, permissions
- Location-Based Visibility - Only visible within 100ft of recognized public places
- Interactive Map View - See nearby users with clustering and zoom controls
- Profile Management - Edit profile picture, interests, and communication intent
- **Swipe-to-Signal** - Intuitive swipe-up gesture to go visible
- **Mock User System** - 8 realistic demo profiles for testing
- **Responsive Design** - Optimized for iPhone with proper safe areas

### In Progress / Planned
- **Real Backend Integration** - Currently using mock data and local storage
- **Push Notifications** - Status change alerts and location-based notifications
- **Chat Functionality** - Direct messaging between users
- **Advanced Filtering** - Filter by interests, age, distance
- **Block/Report Features** - User safety and moderation tools
- **Analytics & Metrics** - User engagement tracking
- **Social Features** - Friend connections, activity feed

## Tech Stack

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
  
### Current Backend Status
- **Local Storage Only** - UserDefaults for persistence
- **Mock Data** - Simulated user profiles and locations
- **No Server** - All data stored locally on device

## Screenshots

*[Screenshots will be added here]*

## Getting Started

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

## Project Structure

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

### Location Settings
- **Visibility Radius**: 100 feet (configurable in `AppConstants.swift`)
- **Update Frequency**: Real-time with battery optimization
- **Permission Required**: Location When In Use

### Mock Data
- **8 Demo Users** - Realistic profiles with varied interests
- **Random Locations** - Within 100ft of venue center
- **Dynamic Visibility** - Some users visible, some not

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

**Made with ❤️ using SwiftUI and modern iOS development practices** 
