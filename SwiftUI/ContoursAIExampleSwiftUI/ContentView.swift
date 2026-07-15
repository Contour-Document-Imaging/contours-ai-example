import SwiftUI
import ContoursAI_SDK

final class ViewModel {
    var captureSide: String = ""
    var docType: String = ""
}

private enum CaptureTab: Int, CaseIterable, Identifiable {
    case check = 101
    case id = 102
    case passport = 103
    case selfie = 104

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .check: return "CHECK"
        case .id: return "ID"
        case .passport: return "PASSPORT"
        case .selfie: return "Selfie"
        }
    }

    var screenTitle: String {
        switch self {
        case .check: return "Check Scan"
        case .id: return "ID Scan"
        case .passport: return "Passport Scan"
        case .selfie: return "Take Selfie"
        }
    }

    var description: String {
        switch self {
        case .check: return "Capture the front or back side of the check."
        case .id: return "Capture the front and back side of the ID."
        case .passport: return "Capture the passport front face only."
        case .selfie: return "Capture your selfie"
        }
    }

    var frontLabel: String {
        switch self {
        case .check: return "Front check"
        case .id: return "Front ID"
        case .passport: return "Passport Front Face"
        case .selfie: return "User Selfie"
        }
    }

    var backLabel: String? {
        switch self {
        case .check: return "Rear check"
        case .id: return "Rear ID"
        case .passport, .selfie: return nil
        }
    }

    var documentCaptureType: String {
        switch self {
        case .check: return "check"
        case .id: return "id"
        case .passport: return "passport"
        case .selfie: return "selfie"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: CaptureTab = .check
    @State private var isShowingSDK = false
    @State private var frontImage: UIImage?
    @State private var rearImage: UIImage?

    private let viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(red: 0.969, green: 0.937, blue: 0.886),
                    Color(red: 0.847, green: 0.910, blue: 0.937)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack {
                    heroCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }

            bottomTabBar
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
        .onAppear {
            applyDocumentUI(for: .check, resetImages: false)
        }
        .fullScreenCover(isPresented: $isShowingSDK) {
            ContoursSDK(
                captureSide: viewModel.captureSide,
                docType: viewModel.docType,
                frontImage: $frontImage,
                rearImage: $rearImage
            )
            .ignoresSafeArea(.all)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(selectedTab.screenTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(textStrong)
                .padding(.bottom, 6)

            Text("Powered by Native iOS SwiftUI")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(textMuted)
                .padding(.bottom, 12)

            Text(selectedTab.description)
                .font(.system(size: 15))
                .foregroundStyle(textMuted)
                .padding(.bottom, 20)

            VStack(spacing: 16) {
                PreviewTile(
                    title: selectedTab.frontLabel,
                    image: frontImage
                ) {
                    openScanner(for: .front)
                }

                if let backLabel = selectedTab.backLabel {
                    PreviewTile(
                        title: backLabel,
                        image: rearImage
                    ) {
                        openScanner(for: .back)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(red: 1.0, green: 0.988, blue: 0.973).opacity(0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color(red: 0.184, green: 0.278, blue: 0.341).opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)
    }

    private var bottomTabBar: some View {
        HStack(spacing: 4) {
            ForEach(CaptureTab.allCases) { tab in
                Button {
                    applyDocumentUI(for: tab)
                } label: {
                    Text(tab.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? .white : textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedTab == tab ? textStrong : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0.184, green: 0.278, blue: 0.341).opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 8)
    }

    private func applyDocumentUI(for tab: CaptureTab, resetImages: Bool = true) {
        selectedTab = tab
        if resetImages {
            frontImage = nil
            rearImage = nil
        }
    }

    private func openScanner(for side: ContoursAI_SDK.DocumentSide) {
        viewModel.docType = selectedTab.documentCaptureType
        viewModel.captureSide = selectedTab == .selfie ? "" : side.rawValue
        isShowingSDK = true
    }

    private var textStrong: Color {
        Color(red: 0.094, green: 0.212, blue: 0.259)
    }

    private var textMuted: Color {
        Color(red: 0.373, green: 0.467, blue: 0.510)
    }
}

private struct PreviewTile: View {
    let title: String
    let image: UIImage?
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.094, green: 0.212, blue: 0.259))

            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(red: 0.925, green: 0.965, blue: 0.980))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0.173, green: 0.251, blue: 0.310).opacity(0.14), lineWidth: 1)
                        )

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        Text(title)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 0.373, green: 0.467, blue: 0.510))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(maxWidth:.infinity, alignment: .leading)
                .frame(height: 220)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}
