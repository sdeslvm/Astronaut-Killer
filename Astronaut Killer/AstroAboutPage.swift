import SwiftUI

/// A customizable informational card component for displaying static content.
struct InformationCard: View {
    // MARK: - Properties
    
    /// The title displayed at the top of the card.
    private let title: String
    
    /// The main message or description shown inside the card.
    private let message: String
    
    /// Optional icon system name for visual representation.
    private let iconName: String?

    // MARK: - Initializer
    
    /// Initializes a new instance of `InformationCard`.
    /// - Parameters:
    ///   - title: The title text to display.
    ///   - message: The main descriptive text.
    ///   - iconName: Optional SF Symbol name for an icon.
    init(title: String, message: String, iconName: String? = nil) {
        self.title = title
        self.message = message
        self.iconName = iconName
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
