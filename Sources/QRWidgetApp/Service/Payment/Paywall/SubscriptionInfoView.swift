
import SwiftUI

struct SubscriptionInfoView: View {
    let trialText: String
    let priceText: String
    let isSelected: Bool
    let isPopular: Bool

    @Binding var titleHeight: CGFloat
    @Binding var subtitleHeight: CGFloat

    let dividerColor = Color(UIColor.white.withAlphaComponent(0.5))

    var body: some View {
            ZStack(alignment: .top) {
                VStack(spacing: 12) {
                    Text(trialText)
                        .font(Font.system(size: 15, weight: .semibold, design: .default))
                        .padding(.horizontal, 8)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(GeometryReader {
                            Color.clear
                                .preference(
                                    key: TitleHeightKey.self,
                                    value: $0.frame(in: .local).size.height
                                )
                        })
                        .frame(minHeight: titleHeight)

                    Rectangle().fill(dividerColor).frame(height: 1, alignment: .center)

                    Text(priceText)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                        .font(Font.system(size: 15, weight: .semibold, design: .default))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(GeometryReader {
                            Color.clear
                                .preference(
                                    key: SubtitleHeightKey.self,
                                    value: $0.frame(in: .local).size.height
                                )
                        })
                        .frame(minHeight: subtitleHeight)
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.yellowOnboarding : dividerColor, lineWidth: 2)
                )

                if isPopular {
                    Text(L10n.Paywall.popular)
                        .font(Font.system(size: 12, weight: .semibold, design: .default))
                        .padding(.horizontal)
                        .background(Color.yellowOnboarding)
                        .foregroundColor(Color.primaryColor)
                        .clipShape(Capsule(style: .circular))
                        .offset(y: -6)
                }
        }
            .contentShape(Rectangle())
    }
}

//
//struct SubscriptionInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ZStack {
//                Color(UIColor.primaryColor)
//                SubscriptionInfoView(trialText: "7 days free", priceText: "Then $9.99 / month", isSelected: false, isPopular: true, minHeight: 0)
//                    .padding()
//            }
//
//            ZStack {
//                Color(UIColor.primaryColor)
//                SubscriptionInfoView(trialText: "7 days free", priceText: "Then $9.99 / month", isSelected: true, isPopular: false, minHeight: 0)
//                    .padding(.horizontal, 100)
//            }
//        }
//
//        .previewLayout(.fixed(width: 300, height: 400))
//
//    }
//}
