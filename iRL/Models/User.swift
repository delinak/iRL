import Foundation
import CoreLocation

struct User: Identifiable, Codable {
    let id = UUID()
    var name: String
    var age: Int
    var profileImage: Data?
    var interests: [String]
    var favoritePlaces: [String]
    var communicationIntent: String
    var isVisible: Bool = false
    var currentMood: String = ""
    var location: CLLocationCoordinate2D?
    var lastActive: Date = Date()
    
    // Computed properties
    var displayName: String {
        return name.isEmpty ? "Anonymous" : name
    }
    
    var isActive: Bool {
        return Date().timeIntervalSince(lastActive) < 300 // 5 minutes
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
} 