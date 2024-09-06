import SwiftUI

@main
struct Plane_Giper_AttackApp: App {
    
    @UIApplicationDelegateAdaptor(PlaneGiperAttackDelegate.self) var planeGiperAttackDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
