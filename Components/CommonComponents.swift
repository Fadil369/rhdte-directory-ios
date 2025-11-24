// Brainsait Maplinc - Common UI Components
// Reusable SwiftUI components for the healthcare directory app

import SwiftUI

// MARK: - Loading View

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(Color("BrainSAITGreen"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Rating Stars View

struct RatingStarsView: View {
    let rating: Double
    let maxRating: Int = 5
    let size: CGFloat = 14
    let color: Color = .yellow

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .font(.system(size: size))
                    .foregroundColor(color)
            }
        }
    }

    private func starType(for index: Int) -> String {
        let threshold = Double(index) + 0.5
        if rating >= Double(index + 1) {
            return "star.fill"
        } else if rating >= threshold {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let text: String
    let color: Color
    var icon: String?

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
            }

            Text(text)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(4)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .foregroundColor(valueColor)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var action: String?
    var onAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if let action = action, let onAction = onAction {
                Button(action, action: onAction)
                    .font(.subheadline)
                    .foregroundColor(Color("BrainSAITGreen"))
            }
        }
    }
}

// MARK: - Card View

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("BrainSAITGreen"))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
    }
}

// MARK: - Search Field

struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSubmit: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        RatingStarsView(rating: 4.5)

        BadgeView(text: "24/7", color: .blue, icon: "clock.fill")

        InfoRow(icon: "phone", title: "Phone", value: "+966 11 123 4567")

        PrimaryButton("Book Now", icon: "calendar") {}

        SecondaryButton("View Details", icon: "info.circle") {}

        SearchField(text: .constant(""))
    }
    .padding()
}
