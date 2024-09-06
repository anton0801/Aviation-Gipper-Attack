import SwiftUI

struct TutorialView: View {
    
    @Binding var showedTutorial: Bool
    @State var currentIndexTutorial = 0 {
        didSet {
            if currentIndexTutorial < 4 {
                withAnimation(.linear(duration: 1.0)) {
                    currentTutorialImage = "tutorial_\(currentIndexTutorial + 1)"
                }
            } else {
                withAnimation(.linear) {
                    showedTutorial = true
                }
            }
        }
    }
    @State var currentTutorialImage = "tutorial_1"
    
    var body: some View {
        HStack {
            Image("pers")
                .offset(y: 50)

            Spacer()
            
            VStack {
                Image(currentTutorialImage)
                    .offset(y: 15)
                Button {
                    currentIndexTutorial += 1
                } label: {
                    ZStack {
                        Image("btn_background")
                        Text("OKEY")
                            .font(.custom("Philosopher-Bold", size: 32))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -15)
            }
            
            Spacer()
            
        }
        .edgesIgnoringSafeArea(.leading)
        .background(
            Image("tutorial_bg")
                .resizable()
                .frame(minWidth: UIScreen.main.bounds.width,
                       minHeight: UIScreen.main.bounds.height + 50)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    TutorialView(showedTutorial: .constant(false))
}
