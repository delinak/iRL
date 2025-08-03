import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showingVisibilitySheet = false
    @State private var selectedPlaceType = "All"
    @State private var selectedDistance = "5 mi"
    @State private var dragOffset: CGFloat = 0
    
    let placeTypes = ["All", "Cafés", "Restaurants", "Shops", "Parks", "Bars", "Gyms"]
    let distances = ["1 mi", "5 mi", "10 mi", "25 mi"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Bar
                    topBar
                    
                    // Filter Bar
                    filterBar
                    
                    // Places Feed
                    placesFeed
                }
                
                // Status Swipe Button (Bottom)
                VStack {
                    Spacer()
                    statusSwipeButton
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingVisibilitySheet) {
                VisibilitySheet()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height < 0 {
                            dragOffset = abs(value.translation.height)
                        }
                    }
                    .onEnded { value in
                        if value.translation.height < -50 && !appState.isVisible {
                            showingVisibilitySheet = true
                        }
                        dragOffset = 0
                    }
            )
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Logo
            Text("iRL")
                .font(.custom("Futura", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            Spacer()
            
            // Profile Picture + Phrase (Center-aligned)
            HStack(spacing: 12) {
                // Profile image
                if let imageData = appState.currentUser?.profileImage,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(appState.isVisible ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                } else {
                    Circle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        )
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(appState.currentUser?.displayName ?? "Anonymous")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(appState.currentUser?.communicationIntent ?? "Set your status")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Location indicator
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(appState.locationService.isLocationEnabled ? .green : .red)
                
                Text("100ft")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Color(.systemBackground)
                .overlay(
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
        )
    }
    
    // MARK: - Filter Bar
    private var filterBar: some View {
        VStack(spacing: 12) {
            // Place Type Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(placeTypes, id: \.self) { type in
                        FilterChip(
                            title: type,
                            isSelected: selectedPlaceType == type,
                            action: { selectedPlaceType = type }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Distance Filter
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text("Within:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Menu {
                    ForEach(distances, id: \.self) { distance in
                        Button(distance) {
                            selectedDistance = distance
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedDistance)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Text("\(mockPlaces.count) places nearby")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
    
    // MARK: - Places Feed
    private var placesFeed: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredPlaces) { place in
                    PlaceCard(place: place)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100) // Space for swipe button
        }
    }
    
    // MARK: - Status Swipe Button
    private var statusSwipeButton: some View {
        VStack(spacing: 8) {
            // Swipe indicator
            if !appState.isVisible {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .opacity(0.7)
                    
                    Text("Swipe up to go visible")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
            }
            
            // Status button
            Button(action: {
                showingVisibilitySheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: appState.isVisible ? "eye.fill" : "eye.slash.fill")
                        .font(.headline)
                        .foregroundColor(appState.isVisible ? .green : .white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.isVisible ? "You're Visible" : "Go Visible")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(appState.isVisible ? .green : .white)
                        
                        Text(appState.isVisible ? "Others can see you nearby" : "Let others find you")
                            .font(.caption2)
                            .foregroundColor(appState.isVisible ? .green.opacity(0.8) : .white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(appState.isVisible ? .green : .white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(appState.isVisible ? Color.green.opacity(0.1) : Color.orange)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.6), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34) // Safe area bottom
        }
        .background(
            LinearGradient(
                colors: [Color.clear, Color(.systemBackground).opacity(0.8), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
        )
    }
    
    // MARK: - Computed Properties
    private var filteredPlaces: [Place] {
        let filtered = mockPlaces.filter { place in
            selectedPlaceType == "All" || place.category == selectedPlaceType
        }
        return Array(filtered.prefix(20)) // Limit for performance
    }
}

// MARK: - Supporting Views
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.orange : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.green.opacity(0.6), lineWidth: 1)
                        )
                )
        }
    }
}

struct PlaceCard: View {
    let place: Place
    @State private var isLiked = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Place Image
            AsyncImage(url: URL(string: place.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.green.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Image(systemName: place.icon)
                            .font(.title)
                            .foregroundColor(.white)
                    )
            }
            .frame(height: 200)
            .clipped()
            .overlay(
                // Distance badge
                VStack {
                    HStack {
                        Spacer()
                        Text(place.distance)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.6))
                            )
                    }
                    Spacer()
                }
                .padding(12)
            )
            
            // Place Info
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text(place.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text(String(format: "%.1f", place.rating))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        Text(place.category)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !place.description.isEmpty {
                    HStack {
                        Text(place.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        isLiked.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.subheadline)
                                .foregroundColor(isLiked ? .red : .secondary)
                            
                            Text(isLiked ? "Liked" : "Like")
                                .font(.caption)
                                .foregroundColor(isLiked ? .red : .secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.6), lineWidth: 1)
                                )
                        )
                    }
                    
                    Button(action: {
                        // Navigate to place
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                            
                            Text("Navigate")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.6), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                    
                    if place.activeUsers > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("\(place.activeUsers) here")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Mock Data
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let address: String
    let distance: String
    let rating: Double
    let description: String
    let imageURL: String
    let icon: String
    let activeUsers: Int
}

let mockPlaces = [
    Place(name: "Blue Bottle Coffee", category: "Cafés", address: "123 Main St", distance: "0.2 mi", rating: 4.5, description: "Specialty coffee roaster with minimalist aesthetic and artisanal approach to brewing.", imageURL: "", icon: "cup.and.saucer.fill", activeUsers: 3),
    Place(name: "The Book Nook", category: "Shops", address: "456 Oak Ave", distance: "0.4 mi", rating: 4.8, description: "Cozy independent bookstore with curated selection and reading nooks.", imageURL: "", icon: "book.fill", activeUsers: 1),
    Place(name: "Green Park", category: "Parks", address: "789 Park Rd", distance: "0.6 mi", rating: 4.2, description: "Urban oasis with walking trails, playground, and dog-friendly areas.", imageURL: "", icon: "tree.fill", activeUsers: 7),
    Place(name: "Artisan Pizza Co.", category: "Restaurants", address: "321 Food St", distance: "0.8 mi", rating: 4.6, description: "Wood-fired Neapolitan pizzas made with locally sourced ingredients.", imageURL: "", icon: "fork.knife", activeUsers: 2),
    Place(name: "Fit Life Gym", category: "Gyms", address: "654 Fitness Blvd", distance: "1.1 mi", rating: 4.3, description: "Modern fitness facility with state-of-the-art equipment and group classes.", imageURL: "", icon: "dumbbell.fill", activeUsers: 5),
]

// MARK: - Visibility Sheet
struct VisibilitySheet: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var tempProfileImage: Data?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("Go Visible")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Make yourself visible to others nearby")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Profile picture section
                VStack(spacing: 16) {
                    Text("Update Profile Picture")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let imageData = tempProfileImage, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.orange, lineWidth: 2)
                                )
                        } else {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundColor(.orange)
                                )
                        }
                    }
                    
                    Text("Take a new photo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button("Go Visible") {
                        if let newImage = tempProfileImage {
                            // Update profile image
                            appState.updateUserProfile(profileImage: newImage)
                        }
                        appState.setVisibility(true)
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                            .fill(Color.orange)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                    .stroke(Color.green.opacity(0.6), lineWidth: 1)
                            )
                    )
                    .disabled(!appState.locationService.isLocationEnabled)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Go Visible")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $tempProfileImage)
            }
        }
    }
}