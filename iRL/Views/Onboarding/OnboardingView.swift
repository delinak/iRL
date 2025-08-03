import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {  
                // Progress indicator
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                Spacer()
                // iRL title at top center
                if viewModel.currentStep != .welcome {
                VStack(spacing: 8) {
                  Text("iRL.")
                        .font(.custom("Futura", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Be seen. Be social. Be iRL.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 30)
                .padding(.bottom, 10)
                        
                Spacer()
                }
                // Content
                TabView(selection: $viewModel.currentStep) {
                    // Step 1: Welcome
                    WelcomeStepView()
                        .tag(OnboardingStep.welcome)
                    
                    // Step 2: Name & Photo
                    NamePhotoStepView(
                        name: $viewModel.name,
                        profileImage: $viewModel.profileImage
                    )
                    .tag(OnboardingStep.namePhoto)
                    
                    // Step 3: Birthday
                    BirthdayStepView(
                        birthday: $viewModel.birthday,
                        isUserOldEnough: viewModel.isUserOldEnough
                    )
                    .tag(OnboardingStep.birthday)
                    
                    // Step 4: Interests
                    InterestsStepView(
                        selectedInterests: $viewModel.selectedInterests,
                        favoriteThirdPlace: $viewModel.favoriteThirdPlace
                    )
                    .tag(OnboardingStep.interests)
                    
                    // Step 5: Instructions & Permissions
                    InstructionsStepView()
                        .tag(OnboardingStep.instructions)
                    
                    // Step 6: Notifications
                    NotificationsStepView()
                        .tag(OnboardingStep.notifications)
                    
                    // Step 7: Final Setup
                    FinalSetupStepView()
                        .tag(OnboardingStep.finalSetup)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: AppConstants.animationDuration), value: viewModel.currentStep)
                
                // Navigation buttons
                HStack {
                    if viewModel.currentStep != .welcome {
                        Button(action: {
                            viewModel.previousStep()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                        .fill(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                                .stroke(Color.green.opacity(0.6), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.currentStep == .finalSetup {
                            viewModel.completeOnboarding(appState: appState)
                        } else {
                            viewModel.nextStep()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                    .fill(viewModel.canProceed ? Color.orange : Color(.systemGray4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                            .stroke(Color.green.opacity(0.6), lineWidth: 1)
                                    )
                            )
                    }
                    .disabled(!viewModel.canProceed)
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
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Onboarding Steps
struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                Text("iRL.")
                        .font(.custom("Futura", size: 65))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Be seen. Be social. Be iRL.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct NamePhotoStepView: View {
    @Binding var name: String
    @Binding var profileImage: Data?
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 32) {
                // Photo upload
                VStack(spacing: 16) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        if let imageData = profileImage, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.orange, lineWidth: 3)
                                )
                        } else {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.title)
                                            .foregroundColor(.orange)
                                        
                                        Text("Add Photo")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                )
                        }
                    }
                    
                    Text("Tap to add a profile photo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Name input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                    
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(ModernTextFieldStyle())
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $profileImage)
        }
    }
}

struct BirthdayStepView: View {
    @Binding var birthday: Date
    let isUserOldEnough: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Enter your birthday")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                .fill(Color(.systemBackground).opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                
                if !isUserOldEnough {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Text("You must be 18 or older to use this app.")
                            .font(.body)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                
                // Legal warning
                Text("By continuing, you confirm you are at least 18 years old.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct InterestsStepView: View {
    @Binding var selectedInterests: Set<String>
    @Binding var favoriteThirdPlace: String
    
    private let thirdPlaces = [
        "Coffee Shop",
        "Park",
        "Bookstore",
        "Library",
        "Café",
        "Museum",
        "Gym",
        "Restaurant"
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                // Interests
                VStack(spacing: 16) {
                    Text("What are your interests?")
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
                
                // Third place
                VStack(spacing: 16) {
                    Text("Favorite 3rd place?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(thirdPlaces, id: \.self) { place in
                            InterestChip(
                                title: place,
                                isSelected: favoriteThirdPlace == place
                            ) {
                                favoriteThirdPlace = place
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct InstructionsStepView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("Location-Based Visibility")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Your profile is only visible when you're within 100 feet of a recognized public place, like a coffee shop, bookstore. etc,.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("iRL will automatically turn your status on and off based on your location. So you're always in control.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Location permission
                PermissionRow(
                    icon: "location.fill",
                    title: "Location Access",
                    description: "Required for location-based visibility",
                    isGranted: appState.locationService.authorizationStatus == .authorizedWhenInUse
                ) {
                    appState.locationService.requestLocationPermission()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct NotificationsStepView: View {
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("Stay Informed")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("You'll get a notification when your status turns off after you leave a location.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps you stay aware of your visibility status and maintain control over your privacy.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Notification permission
                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Get notified about status changes",
                    isGranted: false // TODO: Implement notification permissions
                ) {
                    // TODO: Request notification permissions
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct FinalSetupStepView: View {
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("Almost Ready!")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        Text("A phrase and profile picture are required to go public and view other profiles.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("You can change your profile picture and phrase anytime in the profile settings.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Helper Views
struct InterestChip: View {
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
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.orange : Color(.systemGray5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.green.opacity(0.6), lineWidth: 1)
                        )
                )
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isGranted ? .green : .orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !isGranted {
                Button("Grant") {
                    action()
                }
                .font(.caption)
                .foregroundColor(.orange)
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
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .fill(Color(.systemBackground).opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                        .stroke(Color.orange.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Modern Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .fill(Color(.systemBackground).opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: Data?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
} 