//
//  AvatarView.swift
//  Kudao
//

import SwiftUI

/// Circular avatar: photo when available, otherwise initials on a warm gradient.
struct AvatarView: View {
    let name: String
    let photoData: Data?
    var size: CGFloat = 56
    var ringColor: Color = .clear
    var ringWidth: CGFloat = 0

    private var image: UIImage? {
        guard let photoData else { return nil }
        return UIImage(data: photoData)
    }

    var body: some View {
        Circle()
            .fill(Palette.avatarGradient(for: name))
            .frame(width: size, height: size)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                } else {
                    Text(initials)
                        .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .clipShape(.circle)
            .overlay {
                Circle().strokeBorder(ringColor, lineWidth: ringWidth)
            }
            .accessibilityHidden(true)
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init)
        return parts.isEmpty ? "?" : parts.joined().uppercased()
    }
}

#Preview {
    HStack(spacing: 16) {
        AvatarView(name: "Giulia Rossi", photoData: nil, size: 72)
        AvatarView(name: "Marco", photoData: nil, size: 56)
    }
    .padding()
    .background(Palette.background)
}
