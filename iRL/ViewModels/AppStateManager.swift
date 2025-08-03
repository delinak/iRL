import Foundation
import CoreLocation
import Combine
import SwiftUI // Added for UIGraphicsImageRenderer

class AppStateManager: ObservableObject {
    @Published var currentUser: User?
    @Published var nearbyUsers: [User] = []
    @Published var hasCompletedOnboarding: Bool = false
    @Published var isVisible: Bool = false
    @Published var currentMood: String = ""
    @Published var selectedTab: Tab = .home
    
    private let _locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    enum Tab {
        case home, map, profile
    }
    
    init() {
        setupBindings()
        loadUserData()
        generateDemoUsers()
    }
    
    private func setupBindings() {
        // Monitor location changes and update visibility
        _locationService.$isWithinVisibilityRadius
            .sink { [weak self] isWithinRadius in
                if !isWithinRadius && self?.isVisible == true {
                    self?.setVisibility(false, reason: "Outside visibility radius")
                }
            }
            .store(in: &cancellables)
        
        // Update user location when it changes
        _locationService.$currentLocation
            .sink { [weak self] location in
                if let location = location {
                    self?.updateUserLocation(location)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - User Management
    func createUser(name: String, age: Int, interests: [String], favoritePlaces: [String], communicationIntent: String, profileImage: Data? = nil) {
        let user = User(
            name: name,
            age: age,
            profileImage: profileImage,
            interests: interests,
            favoritePlaces: favoritePlaces,
            communicationIntent: communicationIntent
        )
        currentUser = user
        hasCompletedOnboarding = true
        saveUserData()
    }
    
    func updateUserProfile(name: String? = nil, interests: [String]? = nil, favoritePlaces: [String]? = nil, communicationIntent: String? = nil, profileImage: Data? = nil) {
        guard var user = currentUser else { return }
        
        if let name = name { user.name = name }
        if let interests = interests { user.interests = interests }
        if let favoritePlaces = favoritePlaces { user.favoritePlaces = favoritePlaces }
        if let communicationIntent = communicationIntent { user.communicationIntent = communicationIntent }
        if let profileImage = profileImage { user.profileImage = profileImage }
        
        currentUser = user
        saveUserData()
    }
    
    private func updateUserLocation(_ location: CLLocation) {
        guard var user = currentUser else { return }
        user.location = location.coordinate
        user.lastActive = Date()
        currentUser = user
        saveUserData()
    }
    
    // MARK: - Visibility Management (Simplified Signal Feature)
    func setVisibility(_ visible: Bool, reason: String? = nil) {
        guard var user = currentUser else { return }
        
        // Check if we're within the visibility radius (100 feet)
        if visible && !_locationService.isWithinVisibilityRadius {
            // Show alert that visibility is limited to certain areas
            return
        }
        
        user.isVisible = visible
        user.lastActive = Date()
        currentUser = user
        isVisible = visible
        
        if let reason = reason {
            print("Visibility changed: \(visible) - \(reason)")
        }
        
        saveUserData()
    }
    
    func updateMood(_ mood: String) {
        guard var user = currentUser else { return }
        user.currentMood = mood
        currentUser = user
        currentMood = mood
        saveUserData()
    }
    
    // MARK: - Data Persistence
    private func saveUserData() {
        guard let user = currentUser else { return }
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
        
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }
    
    private func loadUserData() {
        // First check if onboarding was completed
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Only load user data if onboarding was completed
        if hasCompletedOnboarding {
            if let data = UserDefaults.standard.data(forKey: "currentUser"),
               let user = try? JSONDecoder().decode(User.self, from: data) {
                currentUser = user
                isVisible = user.isVisible
                currentMood = user.currentMood
            }
        }
    }
    
    // MARK: - Reset Methods (for testing)
    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentUser = nil
        isVisible = false
        currentMood = ""
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
    
    // MARK: - Demo Data
    private func generateDemoUsers() {
        // Create a simple default profile image (a colored circle with initials)
        let defaultImageData = createDefaultProfileImage()
        
        let demoUsers = [
            User(
                name: "Alex Chen",
                age: 28,
                profileImage: defaultImageData,
                interests: ["Coffee & Cafés", "Books & Reading", "Photography"],
                favoritePlaces: ["Blue Bottle Coffee", "The Book Nook"],
                communicationIntent: "Open to casual conversation about books and coffee"
            ),
            User(
                name: "Sam Rivera",
                age: 24,
                profileImage: defaultImageData,
                interests: ["Music", "Art & Museums", "Street Photography"],
                favoritePlaces: ["SFMOMA", "Golden Gate Park"],
                communicationIntent: "Looking for creative connections and art discussions"
            ),
            User(
                name: "Jordan Kim",
                age: 31,
                profileImage: defaultImageData,
                interests: ["Technology", "Outdoor Activities", "Hiking"],
                favoritePlaces: ["Golden Gate Park", "Crissy Field"],
                communicationIntent: "Interested in tech discussions and outdoor adventures"
            ),
            User(
                name: "Taylor Morgan",
                age: 26,
                profileImage: defaultImageData,
                interests: ["Food & Cooking", "Travel", "Wine Tasting"],
                favoritePlaces: ["Ferry Building", "Artisan Pizza Co."],
                communicationIntent: "Foodie conversations welcome, always up for restaurant recommendations"
            ),
            User(
                name: "Casey Johnson",
                age: 29,
                profileImage: defaultImageData,
                interests: ["Fitness", "Yoga", "Healthy Living"],
                favoritePlaces: ["Fit Life Gym", "Green Park"],
                communicationIntent: "Looking for workout buddies and wellness discussions"
            ),
            User(
                name: "Riley Davis",
                age: 25,
                profileImage: defaultImageData,
                interests: ["Gaming", "Anime", "Tech"],
                favoritePlaces: ["Blue Bottle Coffee", "The Book Nook"],
                communicationIntent: "Gamer and tech enthusiast, love discussing new releases"
            ),
            User(
                name: "Quinn Williams",
                age: 27,
                profileImage: defaultImageData,
                interests: ["Dogs", "Outdoor Activities", "Community Events"],
                favoritePlaces: ["Green Park", "Golden Gate Park"],
                communicationIntent: "Dog lover and community organizer, always up for park meetups"
            ),
            User(
                name: "Avery Thompson",
                age: 30,
                profileImage: defaultImageData,
                interests: ["Craft Beer", "Live Music", "Local Events"],
                favoritePlaces: ["Artisan Pizza Co.", "Ferry Building"],
                communicationIntent: "Beer enthusiast and live music lover, know all the best local spots"
            )
        ]
        
        // Add random locations within the visibility radius (100ft = ~0.0002 degrees)
        let baseLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        nearbyUsers = demoUsers.map { user in
            var updatedUser = user
            updatedUser.isVisible = Bool.random() // Some users are visible, some aren't
            updatedUser.location = CLLocationCoordinate2D(
                latitude: baseLocation.latitude + Double.random(in: -0.0002...0.0002), // Within ~100ft
                longitude: baseLocation.longitude + Double.random(in: -0.0002...0.0002)
            )
            updatedUser.lastActive = Date().addingTimeInterval(-Double.random(in: 0...300)) // Random activity time
            return updatedUser
        }
    }
    
    // MARK: - Helper Functions
    private func createDefaultProfileImage() -> Data? {
        // Create a simple default profile image programmatically
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Background circle
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(ovalIn: rect)
            UIColor.orange.setFill()
            path.fill()
            
            // Add a subtle gradient
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [UIColor.orange.cgColor, UIColor.orange.withAlphaComponent(0.7).cgColor] as CFArray,
                                    locations: [0, 1])!
            context.cgContext.drawLinearGradient(gradient,
                                               start: CGPoint(x: 0, y: 0),
                                               end: CGPoint(x: size.width, y: size.height),
                                               options: [])
            
            // Add a simple icon
            let iconSize: CGFloat = 80
            let iconRect = CGRect(x: (size.width - iconSize) / 2,
                                y: (size.height - iconSize) / 2,
                                width: iconSize,
                                height: iconSize)
            
            let icon = UIImage(systemName: "person.fill")
            icon?.withTintColor(.white, renderingMode: .alwaysOriginal)
                .draw(in: iconRect)
        }
        
        return image.jpegData(compressionQuality: 0.8)
    }
    
    // MARK: - Public Access
    var locationService: LocationService {
        return _locationService
    }
} 
