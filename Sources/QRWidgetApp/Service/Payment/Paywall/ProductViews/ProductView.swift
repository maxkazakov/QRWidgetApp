
import SwiftUI

struct ProductView: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let safePercent: Int?

    let dividerColor = Color(UIColor.white.withAlphaComponent(0.5))

    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                VStack(spacing: 4) {
                    HStack {
                        Text(title)
                            .font(Font.system(size: 18, weight: .semibold, design: .rounded))
                        Spacer()
                    }
                    HStack {
                        Text(subtitle)
                            .font(Font.system(size: 14, weight: .regular, design: .rounded))
                        Spacer()
                    }
                }
                Spacer()

                if let safePercent {
                    Text("Save\n\(safePercent)%")
                        .font(Font.system(size: 18, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellowOnboarding : dividerColor, lineWidth: 3)
            )
        }
        .contentShape(Rectangle())
    }
}


struct ProductView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Color(UIColor.purple)
                ProductView(
                    title: "7 days free",
                    subtitle: "Then $9.99 / month",
                    isSelected: false,
                    safePercent: nil
                )
                    .padding()
            }

            ZStack {
                Color(UIColor.purple)
                ProductView(
                    title: "7 days free",
                    subtitle: "Then $9.99 / month",
                    isSelected: true,
                    safePercent: 61
                )
                    .padding(.horizontal)
            }
        }

        .previewLayout(.fixed(width: 300, height: 400))

    }
}
