import SwiftUI

struct TagChip: View {
    let title: String
    var isSelected = false

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
            )
    }
}
