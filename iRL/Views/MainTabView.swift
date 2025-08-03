import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(AppStateManager.Tab.home)
            
            NearbyActiveView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(AppStateManager.Tab.map)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(AppStateManager.Tab.profile)
        }
        .accentColor(.orange)
    }
} 