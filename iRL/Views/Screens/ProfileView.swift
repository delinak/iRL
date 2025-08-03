import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showingEditProfile = false
    @State private var showingPrivacySettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeaderSection
                    
                    // Visibility settings
                    visibilitySettingsSection
                    
                    // Privacy & permissions
                    privacySection
                    
                    // App settings
                    appSettingsSection
                    
                    // About & support
                    aboutSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.green.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingPrivacySettings) {
                PrivacySettingsView()
            }
        }
    }
    
    private var profileHeaderSection: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                // Profile image and info
                HStack(spacing: 16) {
                    // Profile image
                    Group {
                        if let imageData = appState.currentUser?.profileImage,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Circle()
                                .fill(Color.orange.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.orange)
                                        .font(.title)
                                )
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appState.currentUser?.displayName ?? "Anonymous")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let intent = appState.currentUser?.communicationIntent {
                            Text(intent)
                                .font(.caption)
                                .foregroundColor(.orange)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Edit") {
                        showingEditProfile = true
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
                
                // Interests preview
                if let interests = appState.currentUser?.interests, !interests.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Interests")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                            ForEach(interests.prefix(6), id: \.self) { interest in
                                Text(interest)
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var visibilitySettingsSection: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Visibility Settings")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    GlassmorphicToggle(
                        isOn: $appState.isVisible,
                        title: "Make me visible to others"
                    )
                    
                    if appState.isVisible {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            
                            Text("You're visible within 100ft radius")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    if !appState.currentMood.isEmpty {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.orange)
                            
                            Text("Current mood: \(appState.currentMood)")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button("Change") {
                                // TODO: Show mood picker
                            }
                            .font(.caption)
                            .foregroundColor(.orange)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
    
    private var privacySection: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Privacy & Permissions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Settings") {
                        showingPrivacySettings = true
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
                
                VStack(spacing: 12) {
                    PermissionStatusRow(
                        icon: "location.fill",
                        title: "Location Access",
                        description: "Required to find people nearby",
                        isGranted: appState.locationService.authorizationStatus == .authorizedWhenInUse
                    ) {
                        appState.locationService.requestLocationPermission()
                    }
                    
                    PermissionStatusRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Get notified about nearby people",
                        isGranted: false // TODO: Implement notification permissions
                    ) {
                        // TODO: Request notification permissions
                    }
                }
            }
        }
    }
    
    private var appSettingsSection: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                HStack {
                    Text("App Settings")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    SettingsRow(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        subtitle: "Follow system settings"
                    ) {
                        // TODO: Implement dark mode toggle
                    }
                    
                    SettingsRow(
                        icon: "battery.100",
                        title: "Battery Optimization",
                        subtitle: "Location updates every 30 seconds"
                    ) {
                        // TODO: Show battery optimization info
                    }
                    
                    SettingsRow(
                        icon: "arrow.clockwise",
                        title: "Refresh Location",
                        subtitle: "Update your current location"
                    ) {
                        appState.locationService.startLocationUpdates()
                    }
                }
            }
        }
    }
    
    private var aboutSection: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                HStack {
                    Text("About & Support")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: "How it works",
                        subtitle: "Learn about iRL"
                    ) {
                        // TODO: Show how it works
                    }
                    
                    SettingsRow(
                        icon: "shield",
                        title: "Privacy Policy",
                        subtitle: "How we protect your data"
                    ) {
                        // TODO: Show privacy policy
                    }
                    
                    SettingsRow(
                        icon: "envelope",
                        title: "Contact Support",
                        subtitle: "Get help with the app"
                    ) {
                        // TODO: Show contact support
                    }
                    
                    SettingsRow(
                        icon: "info.circle",
                        title: "App Version",
                        subtitle: "1.0.0"
                    ) {
                        // No action needed
                    }
                    
                    // Reset button for testing
                    SettingsRow(
                        icon: "arrow.clockwise.circle",
                        title: "Reset Onboarding",
                        subtitle: "Start fresh (for testing)"
                    ) {
                        appState.resetOnboarding()
                    }
                }
            }
        }
    }
}

struct PermissionStatusRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isGranted ? .green : .orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button("Grant") {
                    action()
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditProfileView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var selectedInterests: Set<String> = []
    @State private var favoritePlaces: [String] = []
    @State private var newPlace: String = ""
    @State private var showingImagePicker = false
    @State private var tempProfileImage: Data?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture
                    GlassmorphicCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Profile Picture")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                // Profile image
                                Group {
                                    if let imageData = tempProfileImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else if let imageData = appState.currentUser?.profileImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        Circle()
                                            .fill(Color.orange.opacity(0.3))
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.orange)
                                                    .font(.title)
                                            )
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                                )
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Update your profile picture")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    
                                    Button("Choose Photo") {
                                        showingImagePicker = true
                                    }
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Name
                    GlassmorphicCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Name")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    // Interests
                    GlassmorphicCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Interests")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(AppConstants.defaultInterests, id: \.self) { interest in
                                    InterestChip(
                                        title: interest,
                                        isSelected: selectedInterests.contains(interest)
                                    ) {
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else {
                                            selectedInterests.insert(interest)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Favorite places
                    GlassmorphicCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Favorite Places")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack {
                                TextField("Add a place", text: $newPlace)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Add") {
                                    if !newPlace.isEmpty {
                                        favoritePlaces.append(newPlace)
                                        newPlace = ""
                                    }
                                }
                                .disabled(newPlace.isEmpty)
                            }
                            
                            if !favoritePlaces.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(favoritePlaces, id: \.self) { place in
                                        HStack {
                                            Text(place)
                                                .font(.body)
                                            
                                            Spacer()
                                            
                                            Button("Remove") {
                                                favoritePlaces.removeAll { $0 == place }
                                            }
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.green.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        appState.updateUserProfile(
                            name: name,
                            interests: Array(selectedInterests),
                            favoritePlaces: favoritePlaces,
                            profileImage: tempProfileImage
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $tempProfileImage)
            }
            .onAppear {
                loadCurrentData()
            }
        }
    }
    
    private func loadCurrentData() {
        if let user = appState.currentUser {
            name = user.name
            selectedInterests = Set(user.interests)
            favoritePlaces = user.favoritePlaces
        }
    }
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    GlassmorphicCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Privacy Policy")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                PrivacyPolicySection(
                                    title: "Location Data",
                                    description: "Your location is only shared when you're visible and within the 5-mile radius. We never store your location permanently."
                                )
                                
                                PrivacyPolicySection(
                                    title: "Profile Information",
                                    description: "Your name, interests, and communication style are shared with other visible users nearby. You can edit this information anytime."
                                )
                                
                                PrivacyPolicySection(
                                    title: "Visibility Control",
                                    description: "You have complete control over when you're visible. The app automatically disables visibility when you leave the radius."
                                )
                                
                                PrivacyPolicySection(
                                    title: "Data Storage",
                                    description: "All data is stored locally on your device. We don't use external servers or databases."
                                )
                            }
                        }
                    }
                    
                    GlassmorphicCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Safety Features")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                SafetyFeatureRow(
                                    icon: "eye.slash",
                                    title: "Instant Hide",
                                    description: "Turn off visibility immediately"
                                )
                                
                                SafetyFeatureRow(
                                    icon: "location.slash",
                                    title: "Location Control",
                                    description: "Disable location sharing anytime"
                                )
                                
                                SafetyFeatureRow(
                                    icon: "person.crop.circle.badge.xmark",
                                    title: "Block Users",
                                    description: "Block users you don't want to see"
                                )
                                
                                SafetyFeatureRow(
                                    icon: "flag",
                                    title: "Report Issues",
                                    description: "Report inappropriate behavior"
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.green.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Privacy & Safety")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyPolicySection: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct SafetyFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
} 