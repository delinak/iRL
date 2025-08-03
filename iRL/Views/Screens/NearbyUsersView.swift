import SwiftUI

struct NearbyUsersView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedUser: User?
    @State private var showingUserDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                headerSection
                
                // Users list
                if visibleUsers.isEmpty {
                    emptyStateView
                } else {
                    usersList
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.green.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("People Nearby")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingUserDetail) {
                if let user = selectedUser {
                    UserDetailView(user: user)
                }
            }
        }
    }
    
    private var visibleUsers: [User] {
        appState.nearbyUsers.filter { $0.isVisible }
    }
    
    private var headerSection: some View {
        GlassmorphicCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(visibleUsers.count) people visible")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Within 5-mile radius")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(appState.locationService.isLocationEnabled ? .green : .red)
                            .frame(width: 8, height: 8)
                        
                        Text(appState.locationService.isLocationEnabled ? "Location On" : "Location Off")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if appState.isVisible {
                        Text("You're visible")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.2.slash")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Text("No one visible nearby")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Try enabling your visibility or check back later. People need to be within 5 miles and have their visibility turned on.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if !appState.isVisible {
                GlassmorphicButton("Make Yourself Visible") {
                    appState.setVisibility(true)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var usersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(visibleUsers) { user in
                    NearbyUserCard(user: user) {
                        selectedUser = user
                        showingUserDetail = true
                    }
                }
            }
            .padding()
        }
    }
}

struct NearbyUserCard: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            GlassmorphicCard {
                HStack(spacing: 16) {
                    // User avatar
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(String(user.name.prefix(1)))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Name and age
                        HStack {
                            Text(user.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("• \(user.age)")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // Distance
                            Text("0.3 mi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Communication intent
                        Text(user.communicationIntent)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        // Current mood
                        if !user.currentMood.isEmpty {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                
                                Text(user.currentMood)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Spacer()
                            }
                        }
                        
                        // Interests preview
                        if !user.interests.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(user.interests.prefix(3), id: \.self) { interest in
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
                    
                    // Chevron
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
