import SwiftUI
import MapKit

struct NearbyActiveView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001) // Start zoomed in
    )
    @State private var selectedUser: User?
    @State private var selectedCluster: UserCluster?
    @State private var showingUserDetail = false
    @State private var showingClusterDetail = false
    @State private var currentLocation: String = "Blue Bottle Coffee"
    @State private var zoomLevel: Double = 0.001
    @State private var showingProfileOnMap = false
    
    // Zoom levels for clustering behavior
    private let maxZoomIn: Double = 0.0005  // Most zoomed in
    private let maxZoomOut: Double = 0.003  // Most zoomed out (venue boundary)
    private let clusterThreshold: Double = 0.0015 // When to start clustering
    
    var body: some View {
        NavigationView {
            ZStack {
                // Local Area Map with Google Maps-style behavior
                Map(coordinateRegion: $region, annotationItems: userClusters) { cluster in
                    MapAnnotation(coordinate: cluster.centerCoordinate) {
                        if cluster.users.count == 1 {
                            // Individual user dot
                            UserDot(
                                user: cluster.users.first!,
                                isSelected: selectedUser?.id == cluster.users.first!.id,
                                zoomLevel: zoomLevel
                            ) {
                                selectUser(cluster.users.first!)
                            }
                        } else {
                            // Clustered users (Google Maps style)
                            UserClusterDot(
                                cluster: cluster,
                                isSelected: selectedCluster?.id == cluster.id,
                                zoomLevel: zoomLevel
                            ) {
                                selectCluster(cluster)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RegionDidChange"))) { _ in
                    // Update zoom level when region changes
                    zoomLevel = region.span.latitudeDelta
                }
                .gesture(
                    SimultaneousGesture(
                        // Magnification for zooming
                        MagnificationGesture()
                            .onChanged { value in
                                let newSpan = max(maxZoomIn, min(maxZoomOut, zoomLevel / value))
                                withAnimation(.interactiveSpring(response: 0.3)) {
                                    region.span = MKCoordinateSpan(latitudeDelta: newSpan, longitudeDelta: newSpan)
                                }
                            }
                            .onEnded { value in
                                zoomLevel = region.span.latitudeDelta
                                // Auto-cluster/decluster based on new zoom level
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    updateClusters()
                                }
                            },
                        
                        // Drag for panning (constrained to venue area)
                        DragGesture()
                            .onChanged { value in
                                // Constrain panning to venue boundaries
                                let maxOffset = 0.002 // About 200 meters
                                let baseCenter = appState.locationService.currentLocation?.coordinate ?? 
                                               CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                                
                                let deltaLat = -value.translation.y / 10000
                                let deltaLng = value.translation.x / 10000
                                
                                let newLat = max(baseCenter.latitude - maxOffset, 
                                               min(baseCenter.latitude + maxOffset, 
                                                   region.center.latitude + deltaLat))
                                let newLng = max(baseCenter.longitude - maxOffset,
                                               min(baseCenter.longitude + maxOffset,
                                                   region.center.longitude + deltaLng))
                                
                                region.center = CLLocationCoordinate2D(latitude: newLat, longitude: newLng)
                            }
                    )
                )
                
                // Top Header with zoom info
                VStack {
                    topHeader
                    Spacer()
                }
                
                // Selected Profile Card (overlaid on map)
                if let user = selectedUser, showingProfileOnMap {
                    VStack {
                        Spacer()
                        ProfileMapOverlay(user: user) {
                            deselectUser()
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                // Zoom Controls (Google Maps style) - Left center side
                VStack {
                    Spacer()
                    HStack {
                        googleMapsZoomControls
                            .padding(.leading, 20)
                        Spacer()
                    }
                    Spacer()
                    .padding(.bottom, showingProfileOnMap ? 220 : 100)
                }
                
                // Zoom Level Indicator
                VStack {
                    HStack {
                        Spacer()
                        zoomLevelIndicator
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 120)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingUserDetail) {
                if let user = selectedUser {
                    UserDetailView(user: user)
                }
            }
            .sheet(isPresented: $showingClusterDetail) {
                if let cluster = selectedCluster {
                    ClusterDetailView(cluster: cluster) { user in
                        // When user selects someone from cluster
                        selectedCluster = nil
                        showingClusterDetail = false
                        selectUser(user)
                    }
                }
            }
            .onAppear {
                centerOnCurrentLocation()
            }
        }
    }
    
    // MARK: - Top Header
    private var topHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active at")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(currentLocation)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // User count with clustering info
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Text("\(totalActiveUsers) here")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    if zoomLevel > clusterThreshold {
                        Text("• Grouped")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius, 12)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Radius and controls
            HStack {
                Image(systemName: "location.circle")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text("Venue area • Zoom to explore")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Exit Active") {
                    appState.setVisibility(false)
                }
                .font(.caption)
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Color(.systemBackground)
                .opacity(0.95)
                .overlay(
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
        )
    }
    
    // MARK: - Google Maps Style Zoom Controls
    private var googleMapsZoomControls: some View {
        VStack(spacing: 1) {
            Button(action: zoomIn) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
            }
            .disabled(zoomLevel <= maxZoomIn)
            
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)
            
            Button(action: zoomOut) {
                Image(systemName: "minus")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemBackground))
            }
            .disabled(zoomLevel >= maxZoomOut)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        
        // Center location button below
        VStack(spacing: 8) {
            Spacer().frame(height: 8)
            
            Button(action: centerOnCurrentLocation) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.orange)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    )
            }
        }
    }
    
    // MARK: - Zoom Level Indicator
    private var zoomLevelIndicator: some View {
        VStack(spacing: 4) {
            Text(zoomLevelText)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Rectangle()
                .fill(Color.orange)
                .frame(width: zoomBarWidth, height: 3)
                .background(
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 40, height: 3)
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground).opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Computed Properties
    private var userClusters: [UserCluster] {
        let activeUsers = appState.nearbyUsers.filter { $0.isVisible && $0.location != nil }
        return createGoogleMapsStyleClusters(from: activeUsers)
    }
    
    private var totalActiveUsers: Int {
        appState.nearbyUsers.filter { $0.isVisible }.count
    }
    
    private var zoomLevelText: String {
        if zoomLevel <= 0.0007 {
            return "Max zoom"
        } else if zoomLevel <= 0.001 {
            return "Close"
        } else if zoomLevel <= 0.002 {
            return "Medium"
        } else {
            return "Far"
        }
    }
    
    private var zoomBarWidth: CGFloat {
        let progress = (maxZoomOut - zoomLevel) / (maxZoomOut - maxZoomIn)
        return max(4, min(40, progress * 40))
    }
    
    // MARK: - Google Maps Style Clustering
    private func createGoogleMapsStyleClusters(from users: [User]) -> [UserCluster] {
        var clusters: [UserCluster] = []
        var processedUsers: Set<UUID> = []
        
        // Only cluster when zoomed out enough
        let shouldCluster = zoomLevel > clusterThreshold
        
        if !shouldCluster {
            // Show individual users when zoomed in
            return users.map { UserCluster(users: [$0]) }
        }
        
        for user in users {
            if processedUsers.contains(user.id) { continue }
            
            var clusterUsers = [user]
            processedUsers.insert(user.id)
            
            // Dynamic clustering radius based on zoom level
            let clusterRadius = min(100, max(25, zoomLevel * 30000)) // 25-100 feet
            
            for otherUser in users {
                if processedUsers.contains(otherUser.id) { continue }
                
                if let userLocation = user.location,
                   let otherLocation = otherUser.location {
                    let distance = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                        .distance(from: CLLocation(latitude: otherLocation.latitude, longitude: otherLocation.longitude))
                    
                    if distance < clusterRadius {
                        clusterUsers.append(otherUser)
                        processedUsers.insert(otherUser.id)
                    }
                }
            }
            
            clusters.append(UserCluster(users: clusterUsers))
        }
        
        return clusters
    }
    
    // MARK: - User Selection Functions
    private func selectUser(_ user: User) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedUser = user
            selectedCluster = nil
            showingProfileOnMap = true
        }
        
        // Center map on selected user
        if let location = user.location {
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = location
            }
        }
    }
    
    private func deselectUser() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedUser = nil
            showingProfileOnMap = false
        }
    }
    
    private func selectCluster(_ cluster: UserCluster) {
        selectedCluster = cluster
        selectedUser = nil
        showingProfileOnMap = false
        
        // Zoom in on cluster or show detail
        if zoomLevel > 0.0008 {
            // Zoom in to break cluster
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = cluster.centerCoordinate
                let newSpan = max(maxZoomIn, zoomLevel * 0.4)
                region.span = MKCoordinateSpan(latitudeDelta: newSpan, longitudeDelta: newSpan)
                zoomLevel = newSpan
            }
        } else {
            // Show cluster detail sheet
            showingClusterDetail = true
        }
    }
    
    // MARK: - Helper Functions
    private func updateClusters() {
        // Force refresh of clusters based on new zoom level
        objectWillChange.send()
    }
    
    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newSpan = max(maxZoomIn, zoomLevel * 0.6)
            region.span = MKCoordinateSpan(latitudeDelta: newSpan, longitudeDelta: newSpan)
            zoomLevel = newSpan
        }
    }
    
    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newSpan = min(maxZoomOut, zoomLevel * 1.6)
            region.span = MKCoordinateSpan(latitudeDelta: newSpan, longitudeDelta: newSpan)
            zoomLevel = newSpan
        }
    }
    
    private func centerOnCurrentLocation() {
        if let location = appState.locationService.currentLocation {
            withAnimation(.easeInOut(duration: 0.5)) {
                region.center = location.coordinate
            }
        }
    }
}

// MARK: - Enhanced User Dot (with selection state)
struct UserDot: View {
    let user: User
    let isSelected: Bool
    let zoomLevel: Double
    let onTap: () -> Void
    
    // Dynamic sizing based on zoom level
    private var dotSize: CGFloat {
        let baseSize: CGFloat = 32
        let zoomMultiplier = max(0.8, min(1.4, (0.002 - zoomLevel) * 1000))
        return baseSize * zoomMultiplier
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // Profile circle with selection indicator
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? 
                                [Color.orange, Color.orange.opacity(0.7)] :
                                [Color.green, Color.green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: dotSize, height: dotSize)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 2)
                    )
                    .overlay(
                        // Profile image or initial
                        Group {
                            if let imageData = user.profileImage,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: dotSize - 4, height: dotSize - 4)
                                    .clipShape(Circle())
                            } else {
                                Text(String(user.name.prefix(1)))
                                    .font(.system(size: dotSize * 0.4))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .shadow(color: Color.black.opacity(isSelected ? 0.3 : 0.2), 
                           radius: isSelected ? 6 : 4, x: 0, y: 2)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                // Name label (only show when zoomed in enough)
                if zoomLevel < 0.0015 {
                    Text(user.displayName.components(separatedBy: " ").first ?? "")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground).opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Enhanced User Cluster Dot
struct UserClusterDot: View {
    let cluster: UserCluster
    let isSelected: Bool
    let zoomLevel: Double
    let onTap: () -> Void
    
    // Dynamic sizing based on cluster size and zoom level
    private var dotSize: CGFloat {
        let baseSize: CGFloat = 44
        let countMultiplier = min(1.3, 1.0 + CGFloat(cluster.users.count - 1) * 0.05)
        let zoomMultiplier = max(0.9, min(1.2, (0.003 - zoomLevel) * 400))
        return baseSize * countMultiplier * zoomMultiplier
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Cluster circle with dynamic styling
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ?
                                    [Color.orange.opacity(0.9), Color.orange.opacity(0.6)] :
                                    [Color.orange, Color.orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: dotSize, height: dotSize)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: isSelected ? 4 : 3)
                        )
                        .shadow(color: Color.black.opacity(isSelected ? 0.3 : 0.2), 
                               radius: isSelected ? 8 : 6, x: 0, y: 3)
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                    
                    Text("\(cluster.users.count)")
                        .font(.system(size: dotSize * 0.35, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Cluster label (adaptive text)
                if zoomLevel > 0.002 {
                    Text("\(cluster.users.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius, 8)
                                .fill(Color(.systemBackground).opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                } else {
                    Text("\(cluster.users.count) people")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground).opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Profile Map Overlay (replaces bottom panel)
struct ProfileMapOverlay: View {
    let user: User
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
            
            HStack(spacing: 16) {
                // Profile image
                Group {
                    if let imageData = user.profileImage,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(Color.orange.opacity(0.3))
                            .overlay(
                                Text(String(user.name.prefix(1)))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            )
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.orange, lineWidth: 3)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(user.communicationIntent)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if !user.currentMood.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text(user.currentMood)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button("Say Hi") {
                        // Handle say hi action
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange)
                    )
                    
                    Button("View Bio") {
                        // Handle view bio action
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }
            
            // Quick interests preview
            if !user.interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(user.interests.prefix(4), id: \.self) { interest in
                            Text(interest)
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, 16)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.y > 100 {
                        onDismiss()
                    }
                }
        )
    }
}

// MARK: - Enhanced Cluster Detail View
struct ClusterDetailView: View {
    let cluster: UserCluster
    let onUserSelected: (User) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(cluster.users) { user in
                        ClusterUserRow(user: user) {
                            onUserSelected(user)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(cluster.users.count) People Here")
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

struct ClusterUserRow: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile image
                Group {
                    if let imageData = user.profileImage,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(Color.green.opacity(0.3))
                            .overlay(
                                Text(String(user.name.prefix(1)))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            )
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(user.communicationIntent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if !user.currentMood.isEmpty {
                        Text(user.currentMood)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - User Cluster Model (Enhanced)
struct UserCluster: Identifiable {
    let id = UUID()
    let users: [User]
    
    var centerCoordinate: CLLocationCoordinate2D {
        guard !users.isEmpty else { return CLLocationCoordinate2D() }
        
        let validLocations = users.compactMap { $0.location }
        guard !validLocations.isEmpty else { return CLLocationCoordinate2D() }
        
        let avgLat = validLocations.map { $0.latitude }.reduce(0, +) / Double(validLocations.count)
        let avgLng = validLocations.map { $0.longitude }.reduce(0, +) / Double(validLocations.count)
        
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLng)
    }
}