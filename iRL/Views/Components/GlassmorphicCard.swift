import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .fill(
                        Color(.systemBackground)
                            .opacity(0.8)
                    )
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.05),
                                Color.green.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .fill(
                        Color(.systemBackground)
                            .opacity(0.1)
                    )
                    .blur(radius: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .stroke(
                        Color.orange.opacity(0.1),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: AppConstants.shadowRadius,
                x: 0,
                y: 2
            )
    }
}

struct GlassmorphicButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isEnabled ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                        .fill(
                            isEnabled ? 
                                LinearGradient(colors: [Color.orange, Color.orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                .stroke(Color.green.opacity(0.6), lineWidth: 1)
                        )
                )
                .shadow(color: isEnabled ? Color.orange.opacity(0.3) : Color.clear, radius: AppConstants.shadowRadius, x: 0, y: 2)
        }
        .disabled(!isEnabled)
    }
}

struct GlassmorphicToggle: View {
    @Binding var isOn: Bool
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .orange))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .fill(
                    Color(.systemBackground)
                        .opacity(0.8)
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.05),
                            Color.green.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .stroke(
                    Color.orange.opacity(0.1),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(0.1),
            radius: AppConstants.shadowRadius,
            x: 0,
            y: 2
        )
    }
} 