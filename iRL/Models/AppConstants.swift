import Foundation
import CoreLocation

struct AppConstants {
    // Location settings
    static let visibilityRadius: CLLocationDistance = 8046.72 // 5 miles in meters
    static let autoDisableRadius: CLLocationDistance = 1609.34 // 1 mile in meters
    
    // UI Constants
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 8
    static let animationDuration: Double = 0.3
    
    // Default values
    static let defaultInterests = [
        "Coffee & Cafés",
        "Books & Reading",
        "Music",
        "Art & Museums",
        "Outdoor Activities",
        "Technology",
        "Food & Cooking",
        "Travel",
        "Sports",
        "Photography"
    ]
    
    static let defaultMoods = [
        "Open to chat",
        "Working quietly",
        "Reading",
        "People watching",
        "Just hanging out",
        "Exploring",
        "Meeting friends"
    ]
    
    // Privacy settings
    static let locationUpdateInterval: TimeInterval = 30 // seconds
    static let maxLocationHistory: Int = 10
} 