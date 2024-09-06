import SwiftUI
import SpriteKit

struct GameView: View {
    
    @EnvironmentObject var user: User
    @Environment(\.presentationMode) var presMode
    var level: Int
    @State var attackGameScene: AttackGameScene!
    
    var body: some View {
        VStack {
            if let attackGameScene = attackGameScene {
                SpriteView(scene: attackGameScene)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            attackGameScene = AttackGameScene(level: level)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("exit_game")), perform: { _ in
            user.credits = UserDefaults.standard.integer(forKey: "credits")
            user.energy = UserDefaults.standard.integer(forKey: "energy")
            presMode.wrappedValue.dismiss()
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("retry_game")), perform: { _ in
            attackGameScene = attackGameScene.retryGame()
        })
    }
}

#Preview {
    GameView(level: 1)
        .environmentObject(User())
}
