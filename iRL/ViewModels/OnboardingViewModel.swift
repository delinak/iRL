import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case namePhoto = 1
    case birthday = 2
    case interests = 3
    case instructions = 4
    case notifications = 5
    case finalSetup = 6
}

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    
    // User data
    @Published var name: String = ""
    @Published var profileImage: Data?
    @Published var birthday: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @Published var selectedInterests: Set<String> = []
    @Published var favoriteThirdPlace: String = ""
    
    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .namePhoto:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .birthday:
            return isUserOldEnough
        case .interests:
            return selectedInterests.count >= 1 && !favoriteThirdPlace.isEmpty
        case .instructions:
            return true
        case .notifications:
            return true
        case .finalSetup:
            return true
        }
    }
    
    var isUserOldEnough: Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return (ageComponents.year ?? 0) >= 18
    }
    
    var userAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year ?? 0
    }
    
    func nextStep() {
        guard currentStep.rawValue < OnboardingStep.allCases.count - 1 else { return }
        currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1) ?? .welcome
    }
    
    func previousStep() {
        guard currentStep.rawValue > 0 else { return }
        currentStep = OnboardingStep(rawValue: currentStep.rawValue - 1) ?? .welcome
    }
    
    func completeOnboarding(appState: AppStateManager) {
        let user = User(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            age: userAge,
            profileImage: profileImage,
            interests: Array(selectedInterests),
            favoritePlaces: [favoriteThirdPlace],
            communicationIntent: "Open to casual conversation"
        )
        
        appState.createUser(
            name: user.name,
            age: user.age,
            interests: user.interests,
            favoritePlaces: user.favoritePlaces,
            communicationIntent: user.communicationIntent,
            profileImage: user.profileImage
        )
    }
} 