import SwiftUI
import ContoursAI_SDK
// Dummy ViewModel and Enum
class ViewModel {
    var captureSide: String = ""
    var docType: String = ""
}

enum DocumentSide: String {
    case front
    case back
}

struct ContentView: View {
    @State private var selectedTab = 0
    let tabTitles = ["Check", "ID", "Passport"]
    @State private var isShowingSDK = false

    @State var frontImage: UIImage?
    @State var rearImage: UIImage?

    var viewModel: ViewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar
            HStack {
                ForEach(0..<tabTitles.count, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Text(tabTitles[index])
                            .foregroundColor(selectedTab == index ? .black : .gray)
                            .fontWeight(selectedTab == index ? .bold : .regular)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(Color.white)

            // Tab Content
            TabView(selection: $selectedTab) {
                CheckIdView(
                    title: "check",
                    frontImage: $frontImage,
                    rearImage: $rearImage,
                    isShowingSDK: $isShowingSDK,
                    viewModel: viewModel
                )
                .tag(0)

                CheckIdView(
                    title: "id",
                    frontImage: $frontImage,
                    rearImage: $rearImage,
                    isShowingSDK: $isShowingSDK,
                    viewModel: viewModel
                )
                .tag(1)

                PassportView(
                    title: "passport",
                    frontImage: $frontImage,
                    isShowingSDK: $isShowingSDK,
                    viewModel: viewModel
                ).tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }.fullScreenCover(isPresented: $isShowingSDK) {
            ContoursSDK(captureSide: viewModel.captureSide, docType: viewModel.docType, frontImage: $frontImage, rearImage: $rearImage)
            .ignoresSafeArea(.all)
        }
    }
}

// MARK: - Upload View (Used for Check & ID)
struct CheckIdView: View {
    var title: String
    @Binding var frontImage: UIImage?
    @Binding var rearImage: UIImage?
    @Binding var isShowingSDK: Bool

    var viewModel: ViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Front")
                    .font(.headline)

                ZStack {
                    if let image = frontImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                    }
                }
                .onTapGesture {
                    viewModel.docType = title
                    viewModel.captureSide = DocumentSide.front.rawValue
                    isShowingSDK = true
                }

                Text("Rear")
                    .font(.headline)

                ZStack {
                    if let image = rearImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                    }
                }
                .onTapGesture {
                    viewModel.docType = title
                    viewModel.captureSide = DocumentSide.back.rawValue
                    isShowingSDK = true
                }
            }
            .padding()
        }.background(.white)
    }
}

// MARK: - Passport View (Different Layout)
struct PassportView: View {
    var title: String
    @Binding var frontImage: UIImage?
    @Binding var isShowingSDK: Bool
    var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("")
                    .font(.headline)
                
                ZStack {
                    if let image = frontImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                    }
                }
                .onTapGesture {
                    viewModel.docType = title
                    viewModel.captureSide = DocumentSide.front.rawValue
                    isShowingSDK = true
                }
                .padding()
            }
        }.background(.white)
    }
}
